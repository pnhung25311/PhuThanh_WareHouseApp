import Flutter
import UIKit
import Photos
// import flutter_local_notifications
// import FirebaseCore

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var screenshotEventSink: FlutterEventSink?
  private var screenshotObserver: NSObjectProtocol?
  private var lifecycleObservers: [NSObjectProtocol] = []

  /// Khi app bị đưa xuống nền, iOS suspend tiến trình rất nhanh nên
  /// userDidTakeScreenshotNotification không còn bắn tới nữa. Ta ghi lại
  /// thời điểm này để khi app quay lại foreground, quét bù các screenshot
  /// đã chụp trong lúc app đang nền (nhưng chưa bị tắt hẳn).
  private var backgroundEnteredAt: Date?
  private var sentAssetIds = Set<String>()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // FirebaseApp.configure()
    // UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let messenger = engineBridge.applicationRegistrar.messenger()
    let screenshotChannel = FlutterEventChannel(
      name: "com.phuthanh.warehouseapp/screenshot_stream",
      binaryMessenger: messenger
    )
    screenshotChannel.setStreamHandler(self)
  }

  private func startWatchingScreenshots() {
    // Xin quyền Photos ngay từ đầu, thay vì đợi tới lần chụp đầu tiên, để
    // luồng "bắt bù" khi quay lại app đã có quyền sẵn.
    PHPhotoLibrary.requestAuthorization(for: .readWrite) { _ in }

    guard screenshotObserver == nil else { return }
    screenshotObserver = NotificationCenter.default.addObserver(
      forName: UIApplication.userDidTakeScreenshotNotification,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      self?.handleScreenshotTaken()
    }

    lifecycleObservers.append(
      NotificationCenter.default.addObserver(
        forName: UIApplication.didEnterBackgroundNotification,
        object: nil,
        queue: .main
      ) { [weak self] _ in
        self?.backgroundEnteredAt = Date()
      }
    )
    lifecycleObservers.append(
      NotificationCenter.default.addObserver(
        forName: UIApplication.didBecomeActiveNotification,
        object: nil,
        queue: .main
      ) { [weak self] _ in
        self?.catchUpMissedScreenshots()
      }
    )
  }

  private func stopWatchingScreenshots() {
    if let observer = screenshotObserver {
      NotificationCenter.default.removeObserver(observer)
      screenshotObserver = nil
    }
    lifecycleObservers.forEach { NotificationCenter.default.removeObserver($0) }
    lifecycleObservers.removeAll()
  }

  private func handleScreenshotTaken() {
    // Đọc trạng thái app ngay lúc chụp (trên main thread), trước khi chờ async.
    let fromBackground = UIApplication.shared.applicationState != .active
    PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
      guard status == .authorized || status == .limited else { return }
      // Photos needs a brief moment to finish writing the screenshot asset.
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
        self?.fetchLatestScreenshotAsset(fromBackground: fromBackground)
      }
    }
  }

  private func fetchLatestScreenshotAsset(fromBackground: Bool) {
    let fetchOptions = PHFetchOptions()
    fetchOptions.predicate = NSPredicate(
      format: "mediaSubtype = %d", PHAssetMediaSubtype.photoScreenshot.rawValue
    )
    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
    fetchOptions.fetchLimit = 1

    let result = PHAsset.fetchAssets(with: .image, options: fetchOptions)
    guard let asset = result.firstObject,
          let creationDate = asset.creationDate,
          Date().timeIntervalSince(creationDate) <= 10
    else { return }

    exportAndSend(asset: asset, fromBackground: fromBackground)
  }

  /// Gọi khi app quay lại foreground: tìm các screenshot chụp trong lúc
  /// app đang chạy nền (chưa bị tắt hẳn) mà thông báo real-time đã bỏ lỡ.
  private func catchUpMissedScreenshots() {
    guard let since = backgroundEnteredAt else { return }
    backgroundEnteredAt = nil

    let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    guard status == .authorized || status == .limited else { return }

    let fetchOptions = PHFetchOptions()
    fetchOptions.predicate = NSPredicate(
      format: "mediaSubtype = %d AND creationDate > %@",
      PHAssetMediaSubtype.photoScreenshot.rawValue,
      since.addingTimeInterval(-1) as NSDate
    )
    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]

    let result = PHAsset.fetchAssets(with: .image, options: fetchOptions)
    guard result.count > 0 else { return }

    result.enumerateObjects { [weak self] asset, _, _ in
      self?.exportAndSend(asset: asset, fromBackground: true)
    }
  }

  private func exportAndSend(asset: PHAsset, fromBackground: Bool) {
    if sentAssetIds.contains(asset.localIdentifier) { return }
    sentAssetIds.insert(asset.localIdentifier)
    if sentAssetIds.count > 30 { sentAssetIds.removeAll() }

    let imageOptions = PHImageRequestOptions()
    imageOptions.isSynchronous = false
    imageOptions.deliveryMode = .highQualityFormat
    imageOptions.isNetworkAccessAllowed = true

    PHImageManager.default().requestImageDataAndOrientation(
      for: asset,
      options: imageOptions
    ) { [weak self] data, _, _, _ in
      guard let self = self, let data = data else { return }

      let dir = FileManager.default.temporaryDirectory.appendingPathComponent(
        "screenshots", isDirectory: true
      )
      let fileURL = dir.appendingPathComponent("\(Int(Date().timeIntervalSince1970 * 1000)).png")

      do {
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        try data.write(to: fileURL)
        DispatchQueue.main.async {
          self.screenshotEventSink?(["path": fileURL.path, "fromBackground": fromBackground])
        }
      } catch {
        // Ignore: nothing useful to surface if the temp copy fails.
      }
    }
  }
}

extension AppDelegate: FlutterStreamHandler {
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    screenshotEventSink = events
    startWatchingScreenshots()
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    stopWatchingScreenshots()
    screenshotEventSink = nil
    return nil
  }
}
