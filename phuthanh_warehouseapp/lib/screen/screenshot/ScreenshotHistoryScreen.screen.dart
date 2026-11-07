import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phuthanh_warehouseapp/components/QuickFilterBar.custom.dart';
import 'package:phuthanh_warehouseapp/components/ZoomableImage.custom.dart';
import 'package:phuthanh_warehouseapp/helper/ChangeSystemDialog.helper.dart';
import 'package:phuthanh_warehouseapp/helper/DeviceNameHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/FolderPickerHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/MediaLog.helper.dart';
import 'package:phuthanh_warehouseapp/model/screenshot/ListViewOptions.model.dart';
import 'package:phuthanh_warehouseapp/model/screenshot/PendingScreenshot.model.dart';
import 'package:phuthanh_warehouseapp/model/screenshot/ScreenshotInfo.model.dart';
import 'package:phuthanh_warehouseapp/screen/screenshot/FullScreenMemoryImage.screen.dart';
import 'package:phuthanh_warehouseapp/service/PendingScreenshotStore.service.dart';
import 'package:phuthanh_warehouseapp/service/ScreenshotService.service.dart';
import 'package:phuthanh_warehouseapp/service/ScreenshotSettings.service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

const List<String> _kVideoExtensions = [
  '.mp4',
  '.mov',
  '.m4v',
  '.3gp',
  '.avi',
  '.mkv',
  '.webm',
];

bool _isVideoFile(String fileName) {
  final lower = fileName.toLowerCase();
  return _kVideoExtensions.any(lower.endsWith);
}

/// Màn hình chính của "Hệ thống MediaCloud" (xem SystemRegistry):
/// thanh điều hướng dưới gồm "Server" (đã upload lên server) — nút chụp ảnh
/// bằng camera ở giữa — "Local" (ảnh vừa chụp/chụp màn hình, chưa đẩy
/// lên server, có thể đổi tên rồi upload).
class ScreenshotHistoryScreen extends StatefulWidget {
  const ScreenshotHistoryScreen({super.key});

  @override
  State<ScreenshotHistoryScreen> createState() =>
      _ScreenshotHistoryScreenState();
}

class _ScreenshotHistoryScreenState extends State<ScreenshotHistoryScreen> {
  static const int _tabSaved = 0;
  static const int _tabPending = 1;

  final ScreenshotService _service = ScreenshotService();
  final PendingScreenshotStore _pendingStore = PendingScreenshotStore();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  int _currentTab = _tabSaved;
  Future<List<ScreenshotInfo>>? _savedFuture;
  Future<List<PendingScreenshot>>? _pendingFuture;

  final Map<String, Future<Uint8List>> _thumbnailFutures = {};

  // Bytes thumbnail đã tải xong: dựng thẳng từ đây (không qua FutureBuilder)
  // để lọc/sắp xếp lại danh sách không làm thumbnail nháy vòng xoay.
  final Map<String, Uint8List> _thumbnailBytes = {};

  // Chế độ chọn nhiều để xóa (áp dụng cho tab đang mở).
  String _currentFolder = ScreenshotService.defaultFolder;
  // Folder thật gần nhất đã chọn (dùng làm mặc định khi đang xem "Tất cả").
  String _lastRealFolder = ScreenshotService.defaultFolder;
  List<String> _folders = [ScreenshotService.defaultFolder];
  ListViewOptions _options = const ListViewOptions();
  int _pendingTotal = 0; // số file trong Local (hiện trên huy hiệu của tab)
  bool _directUpload = false;
  String _directUploadFolder = ScreenshotService.defaultFolder;
  bool _searching = false;
  String _query = '';
  final TextEditingController _searchController = TextEditingController();
  bool _selecting = false;
  final Set<String> _selectedSaved = {}; // _savedKey(folder/fileName)
  final Set<String> _selectedPending = {}; // filePath
  List<ScreenshotInfo> _savedItems = [];
  List<PendingScreenshot> _pendingItems = [];

  @override
  void initState() {
    super.initState();
    _loadPending();
    _initFolders();
    PendingScreenshotStore.changes.addListener(_onPendingChanged);
    ScreenshotSettings().isDirectUpload().then((value) {
      if (mounted) setState(() => _directUpload = value);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    PendingScreenshotStore.changes.removeListener(_onPendingChanged);
    super.dispose();
  }

  void _onPendingChanged() {
    if (mounted) _loadPending();
  }

  /// Tải thumbnail của mục đã lưu (cache theo tên + thời điểm sửa để cuộn
  /// lên xuống không tải lại; lỗi thì bỏ cache để lần sau thử lại). Ảnh: tải
  /// ảnh gốc; video: lấy khung hình đầu tiên qua URL, không tải cả video.
  String _thumbnailKey(ScreenshotInfo info) =>
      '${info.folderName}/${info.fileName}_${info.lastModified}';

  Future<Uint8List> _thumbnailFor(ScreenshotInfo info) =>
      _cachedThumbnail(_thumbnailKey(info), () => _loadThumbnail(info));

  Future<Uint8List> _loadThumbnail(ScreenshotInfo info) async {
    final deviceName = await DeviceNameHelper.current();
    return _isVideoFile(info.fileName)
        ? _service.remoteVideoThumbnail(
            deviceName,
            info.folderName,
            info.fileName,
            token: info.token,
          )
        : _service.viewScreenshot(
            deviceName,
            info.folderName,
            info.fileName,
            token: info.token,
          );
  }

  Future<Uint8List> _cachedThumbnail(
    String key,
    Future<Uint8List> Function() load,
  ) {
    return _thumbnailFutures.putIfAbsent(key, () async {
      try {
        final bytes = await load();
        _thumbnailBytes[key] = bytes;
        return bytes;
      } catch (_) {
        _thumbnailFutures.remove(key);
        rethrow;
      }
    });
  }

  Widget _thumbnailImage(Uint8List bytes, {required bool isVideo}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.memory(
            bytes,
            fit: BoxFit.cover,
            cacheWidth: 96,
            gaplessPlayback: true,
          ),
          if (isVideo)
            const Center(
              child: Icon(
                Icons.play_circle_fill,
                color: Colors.white70,
                size: 24,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildThumbnailBox(
    String key,
    Future<Uint8List> Function() load, {
    required bool isVideo,
  }) {
    final cached = _thumbnailBytes[key];
    return SizedBox(
      width: 48,
      height: 48,
      child: cached != null
          ? _thumbnailImage(cached, isVideo: isVideo)
          : FutureBuilder<Uint8List>(
              future: _cachedThumbnail(key, load),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Icon(
                    isVideo ? Icons.videocam : Icons.broken_image,
                    color: isVideo ? Colors.red : Colors.grey,
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                return _thumbnailImage(snapshot.data!, isVideo: isVideo);
              },
            ),
    );
  }

  Widget _buildSavedLeading(ScreenshotInfo info) => _buildThumbnailBox(
    _thumbnailKey(info),
    () => _loadThumbnail(info),
    isVideo: _isVideoFile(info.fileName),
  );

  bool _matchesQuery(String fileName) =>
      _query.isEmpty || fileName.toLowerCase().contains(_query.toLowerCase());

  void _startSearch() => setState(() => _searching = true);

  void _stopSearch() {
    _searchController.clear();
    setState(() {
      _searching = false;
      _query = '';
    });
  }

  int get _selectedCount =>
      _currentTab == _tabSaved ? _selectedSaved.length : _selectedPending.length;

  bool get _viewingAll => _currentFolder == ScreenshotService.allFolders;

  /// Khóa chọn của 1 file trên server: gồm cả folder vì ở chế độ "Tất cả" có
  /// thể có 2 file trùng tên ở 2 folder khác nhau.
  String _savedKey(ScreenshotInfo info) => '${info.folderName}/${info.fileName}';

  void _enterSelection({String? savedName, String? pendingPath}) {
    setState(() {
      _selecting = true;
      if (savedName != null) _selectedSaved.add(savedName);
      if (pendingPath != null) _selectedPending.add(pendingPath);
    });
  }

  void _exitSelection() {
    setState(() {
      _selecting = false;
      _selectedSaved.clear();
      _selectedPending.clear();
    });
  }

  void _toggle(Set<String> selected, String key) {
    setState(() {
      if (!selected.remove(key)) selected.add(key);
    });
  }

  bool get _allSelected {
    if (_currentTab == _tabSaved) {
      return _savedItems.isNotEmpty &&
          _savedItems.every((e) => _selectedSaved.contains(_savedKey(e)));
    }
    return _pendingItems.isNotEmpty &&
        _pendingItems.every((e) => _selectedPending.contains(e.filePath));
  }

  /// Chọn tất cả mục đang hiển thị; nếu đã chọn hết rồi thì bỏ chọn hết
  /// (vẫn ở trong chế độ chọn, chỉ thoát khi bấm X hoặc Back).
  void _toggleSelectAll() {
    final deselect = _allSelected;
    setState(() {
      if (deselect) {
        _selectedSaved.clear();
        _selectedPending.clear();
      } else if (_currentTab == _tabSaved) {
        _selectedSaved
          ..clear()
          ..addAll(_savedItems.map(_savedKey));
      } else {
        _selectedPending
          ..clear()
          ..addAll(_pendingItems.map((e) => e.filePath));
      }
    });
  }

  List<PendingScreenshot> get _selectedPendingItems =>
      _pendingItems.where((e) => _selectedPending.contains(e.filePath)).toList();

  /// Chia sẻ các file Local đang chọn qua bảng chia sẻ của hệ điều hành.
  Future<void> _shareSelectedPending() async {
    final files = _selectedPendingItems.map((e) => File(e.filePath)).toList();
    if (files.isEmpty) return;
    await _shareFiles(files);
  }

  /// Đẩy các file Local đang chọn lên server.
  Future<void> _uploadSelectedPending() =>
      _uploadPendingItems(_selectedPendingItems);

  /// Xóa các mục đang chọn ở tab hiện tại (có xác nhận trước khi xóa).
  Future<void> _deleteSelected() async {
    final count = _selectedCount;
    if (count == 0) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Xóa $count mục đã chọn? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    if (_currentTab == _tabSaved) {
      final infos = _savedItems
          .where((e) => _selectedSaved.contains(_savedKey(e)))
          .toList();
      final deviceName = await DeviceNameHelper.current();
      final results = await Future.wait(
        infos.map(
          (i) => _service.deleteScreenshot(deviceName, i.folderName, i.fileName),
        ),
      );
      final deleted = results.where((ok) => ok).length;
      _exitSelection();
      _loadSaved();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(behavior: SnackBarBehavior.floating, content: Text('Đã xóa $deleted/${infos.length} mục')),
      );
    } else {
      await _pendingStore.removePendingByPaths(_selectedPending);
      _exitSelection();
    }
  }

  /// Mở hệ thống: tự chọn folder chính (nếu folder chính không còn thì
  /// `_refreshFolders` đưa về `main`).
  Future<void> _initFolders() async {
    final settings = ScreenshotSettings();
    _directUploadFolder = await settings.directUploadFolder();
    _currentFolder = _directUploadFolder;
    _lastRealFolder = _currentFolder;
    await settings.setCurrentFolder(_currentFolder);
    await _refreshFolders();
    if (mounted) _loadSaved();
  }

  /// Tải danh sách folder; đảm bảo luôn có folder `main` (tạo nếu chưa có)
  /// và folder đang chọn vẫn còn tồn tại.
  Future<void> _refreshFolders() async {
    const main = ScreenshotService.defaultFolder;
    final deviceName = await DeviceNameHelper.current();
    var others = <String>[];
    var loaded = false;
    try {
      final list = await _service.listFolders(deviceName);
      loaded = true;
      others = list.where((f) => f != main).toList();
      if (!list.contains(main)) await _service.createFolder(deviceName, main);
    } catch (_) {}
    if (!mounted) return;

    final folders = [main, ...others];
    if (_viewingAll) {
      // "Tất cả" không phải folder thật nên không cần có trong danh sách.
    } else if (loaded && !folders.contains(_currentFolder)) {
      _currentFolder = main;
      _lastRealFolder = main;
      await ScreenshotSettings().setCurrentFolder(main);
    } else if (!folders.contains(_currentFolder)) {
      folders.add(_currentFolder);
    }
    if (!folders.contains(_lastRealFolder)) _lastRealFolder = main;
    if (loaded && !folders.contains(_directUploadFolder)) {
      _directUploadFolder = main;
      await ScreenshotSettings().setDirectUploadFolder(main);
    }
    setState(() => _folders = folders);
  }

  Future<void> _selectFolder(String folder) async {
    if (folder == _currentFolder) return;
    _exitSelection();
    setState(() => _currentFolder = folder);
    if (folder != ScreenshotService.allFolders) {
      // Chỉ nhớ folder thật (dùng cho popup chụp màn hình), không nhớ "Tất cả".
      _lastRealFolder = folder;
      await ScreenshotSettings().setCurrentFolder(folder);
    }
    _loadSaved();
  }

  Future<void> _createFolder() async {
    final input = await _askNewName(
      '',
      title: 'Tạo folder mới',
      hint: 'Tên folder',
    );
    if (input == null || input.trim().isEmpty) return;
    final name = ScreenshotService.sanitizeFolderName(input);

    try {
      final deviceName = await DeviceNameHelper.current();
      final status = await _service.createFolder(deviceName, name);
      if (status == 200) {
        await _refreshFolders();
        await _selectFolder(name);
        _showSnack('Đã tạo folder "$name"');
      } else if (status == 409) {
        _showSnack('Folder "$name" đã tồn tại');
      } else {
        _showSnack('Tên folder không hợp lệ');
      }
    } catch (e) {
      _showSnack('Lỗi khi tạo folder: $e');
    }
  }

  Future<void> _renameCurrentFolder() async {
    final input = await _askNewName(
      _currentFolder,
      title: 'Đổi tên folder',
      hint: 'Tên folder mới',
    );
    if (input == null || input.trim().isEmpty) return;
    final newName = ScreenshotService.sanitizeFolderName(input);
    if (newName == _currentFolder) return;

    try {
      final deviceName = await DeviceNameHelper.current();
      final status = await _service.renameFolder(
        deviceName,
        _currentFolder,
        newName,
      );
      if (status == 200) {
        if (_directUploadFolder == _currentFolder) {
          _directUploadFolder = newName;
          await ScreenshotSettings().setDirectUploadFolder(newName);
        }
        _currentFolder = newName;
        await ScreenshotSettings().setCurrentFolder(newName);
        await _refreshFolders();
        _loadSaved();
        _showSnack('Đã đổi tên folder thành "$newName"');
      } else if (status == 409) {
        _showSnack('Folder "$newName" đã tồn tại');
      } else {
        _showSnack('Không đổi được tên folder');
      }
    } catch (e) {
      _showSnack('Lỗi khi đổi tên folder: $e');
    }
  }

  Future<void> _deleteCurrentFolder() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa folder'),
        content: Text(
          'Xóa folder "$_currentFolder" và TOÀN BỘ ảnh/video bên trong? '
          'Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      final deviceName = await DeviceNameHelper.current();
      final deleted = await _service.deleteFolder(deviceName, _currentFolder);
      if (!deleted) {
        _showSnack('Không xóa được folder');
        return;
      }
      final removed = _currentFolder;
      _exitSelection();
      _currentFolder = ScreenshotService.defaultFolder;
      _lastRealFolder = _currentFolder;
      await ScreenshotSettings().setCurrentFolder(_currentFolder);
      await _refreshFolders();
      _loadSaved();
      _showSnack('Đã xóa folder "$removed"');
    } catch (e) {
      _showSnack('Lỗi khi xóa folder: $e');
    }
  }

  void _updateOptions(ListViewOptions options) =>
      setState(() => _options = options);

  Widget _buildFolderBar() {
    // "main" và "Tất cả" không đổi tên / xóa được.
    final canManage =
        _currentFolder != ScreenshotService.defaultFolder && !_viewingAll;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 16, right: 4),
      child: Row(
        children: [
          const Icon(Icons.folder, color: Colors.amber),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _currentFolder,
                // Gộp folder đang chọn vào danh sách: ngay lúc mở app, folder
                // chính có thể được chọn trước khi danh sách tải xong.
                items: [
                  const DropdownMenuItem(
                    value: ScreenshotService.allFolders,
                    child: Text(
                      'Tất cả',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  for (final f in {
                    ..._folders,
                    if (!_viewingAll) _currentFolder,
                  })
                    DropdownMenuItem(
                      value: f,
                      child: Text(f, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: _selecting
                    ? null
                    : (value) {
                        if (value != null) _selectFolder(value);
                      },
              ),
            ),
          ),
          IconButton(
            tooltip: 'Tạo folder',
            icon: const Icon(Icons.create_new_folder, color: Colors.blue),
            onPressed: _createFolder,
          ),
          if (canManage)
            PopupMenuButton<String>(
              tooltip: 'Tùy chọn folder',
              onSelected: (value) =>
                  value == 'rename' ? _renameCurrentFolder() : _deleteCurrentFolder(),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'rename', child: Text('Đổi tên folder')),
                PopupMenuItem(
                  value: 'delete',
                  child: Text('Xóa folder', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _loadSaved() {
    setState(() {
      _savedFuture = DeviceNameHelper.current().then(
        (deviceName) => _viewingAll
            ? _service.listByDevice(deviceName)
            : _service.listScreenshots(deviceName, _currentFolder),
      );
    });
  }

  void _loadPending() {
    final future = _pendingStore.getAll();
    setState(() {
      _pendingFuture = future;
    });
    future.then((list) {
      if (mounted && list.length != _pendingTotal) {
        setState(() => _pendingTotal = list.length);
      }
    });
  }

  String _formatSize(int bytes) {
    if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }

  /// Mở menu chọn nguồn thêm media mới: chụp ảnh/quay video bằng camera,
  /// hoặc chọn ảnh/video có sẵn trong thư viện.
  Future<void> _openAddMediaMenu() async {
    await showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text('Chụp ảnh'),
              onTap: () {
                Navigator.pop(ctx);
                _addMedia(source: ImageSource.camera, isVideo: false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam, color: Colors.red),
              title: const Text('Quay video'),
              onTap: () {
                Navigator.pop(ctx);
                _addMedia(source: ImageSource.camera, isVideo: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text('Chọn ảnh/video từ thư viện'),
              subtitle: const Text('Chọn được nhiều file cùng lúc'),
              onTap: () {
                Navigator.pop(ctx);
                _addFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  // Chống mở 2 bộ chọn chồng nhau (bấm 2 lần, hoặc bấm lại trong lúc iOS đang
  // chuẩn bị video): bộ chọn thứ hai sẽ hủy bộ thứ nhất với lỗi
  // `multiple_request`.
  bool _pickerBusy = false;

  Future<void> _runPicker(Future<void> Function() action) async {
    if (_pickerBusy) return;
    _pickerBusy = true;
    try {
      await action();
    } finally {
      _pickerBusy = false;
    }
  }

  bool _isCancelledBySecondRequest(Object error) =>
      error is PlatformException && error.code == 'multiple_request';

  /// Chụp ảnh / quay video bằng camera và đưa vào "Local" (hoặc đẩy thẳng).
  Future<void> _addMedia({
    required ImageSource source,
    required bool isVideo,
  }) => _runPicker(() async {
    try {
      final picker = ImagePicker();
      final picked = isVideo
          ? await picker.pickVideo(source: source)
          : await picker.pickImage(source: source, imageQuality: 90);
      if (picked == null) return;
      await _addFiles([File(picked.path)]);
    } catch (e) {
      if (_isCancelledBySecondRequest(e)) return;
      await _showErrorDialog(
        isVideo ? 'Không lấy được video' : 'Không lấy được ảnh',
        '$e',
      );
    }
  });

  /// Chọn NHIỀU ảnh/video cùng lúc từ thư viện. Nếu bộ chọn chính
  /// (image_picker) báo lỗi (ví dụ iOS không xuất được video) thì thử lại bằng
  /// bộ chọn dự phòng (file_picker); lỗi nào cũng được hiển thị rõ cho người
  /// dùng thay vì im lặng.
  Future<void> _addFromGallery() => _runPicker(_pickFromGalleryOnce);

  Future<void> _pickFromGalleryOnce() async {
    List<File> files;
    try {
      MediaLog.add('Mở bộ chọn thư viện (image_picker)');
      final picked = await ImagePicker().pickMultipleMedia(imageQuality: 90);
      files = picked.map((x) => File(x.path)).toList();
      MediaLog.add('image_picker trả về ${files.length} file');
    } catch (primaryError) {
      MediaLog.add('image_picker lỗi: $primaryError');
      // Bị hủy vì có yêu cầu mở bộ chọn khác: không phải lỗi thật, và không
      // được mở thêm bộ chọn dự phòng (sẽ lại hủy chính bộ chọn đang mở).
      if (_isCancelledBySecondRequest(primaryError)) return;
      try {
        MediaLog.add('Thử bộ chọn dự phòng (file_picker)');
        final result = await FilePicker.pickFiles(
          type: FileType.media,
          allowMultiple: true,
        );
        if (result == null) return;
        files = result.files
            .where((f) => f.path != null)
            .map((f) => File(f.path!))
            .toList();
        MediaLog.add('file_picker trả về ${files.length} file');
      } catch (fallbackError) {
        MediaLog.add('file_picker lỗi: $fallbackError');
        if (_isCancelledBySecondRequest(fallbackError)) return;
        await _showErrorDialog(
          'Không lấy được ảnh/video từ thư viện',
          '$primaryError\n\n$fallbackError',
        );
        return;
      }
    }

    if (files.isEmpty) {
      _showSnack('Không nhận được file nào từ thư viện');
      return;
    }

    try {
      await _addFiles(files);
    } catch (e) {
      await _showErrorDialog('Không thêm được file vào Local', '$e');
    }
  }

  Future<void> _showErrorDialog(String title, String message) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(message)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  /// Đưa các file vừa lấy vào "Local", hoặc đẩy thẳng lên server nếu đang
  /// bật "Đẩy thẳng lên server".
  Future<void> _addFiles(List<File> files) async {
    if (files.isEmpty) return;
    if (_directUpload) {
      await _uploadDirect(files);
      return;
    }

    Future<void> addAll() async {
      for (final file in files) {
        final exists = await file.exists();
        final size = exists ? await file.length() : 0;
        MediaLog.add('Thêm vào Local: ${file.path} (tồn tại=$exists, $size byte)');
        if (!exists || size == 0) {
          throw FileSystemException(
            'File do bộ chọn trả về không tồn tại hoặc rỗng',
            file.path,
          );
        }
        final saved = await _pendingStore.addPending(file);
        MediaLog.add('  -> đã lưu ${saved.path} (tồn tại=${await saved.exists()})');
      }
    }

    // File lớn (video) có thể mất vài giây để đưa vào kho: hiện tiến trình
    // để người dùng không tưởng là app không nhận file.
    var totalBytes = 0;
    for (final file in files) {
      totalBytes += await file.length();
    }
    MediaLog.add('Tổng dung lượng $totalBytes byte, ${files.length} file');
    if (totalBytes >= 5 * 1024 * 1024) {
      await _withLoading('Đang thêm ${files.length} file vào Local...', addAll);
    } else {
      await addAll();
    }
    if (!mounted) return;
    _exitSelection();
    setState(() => _currentTab = _tabPending);
    _loadPending();
    _showSnack('Đã thêm ${files.length} file vào Local');
  }

  /// Đẩy thẳng các file lên folder chính (không lưu vào "Local"). File nào
  /// upload thất bại sẽ được giữ lại trong "Local" để không mất ảnh/video.
  Future<void> _uploadDirect(List<File> files) async {
    final folder = _directUploadFolder;
    final result = await _uploadFiles(files, folder);
    if (!mounted) return;

    _exitSelection();
    final okPaths = result.succeeded.map((f) => f.path).toSet();
    for (final file in files.where((f) => !okPaths.contains(f.path))) {
      await _pendingStore.addPending(file);
    }
    if (!mounted) return;

    if (result.succeeded.isNotEmpty) {
      setState(() => _currentTab = _tabSaved);
      // Chuyển sang folder vừa đẩy lên để thấy ngay kết quả.
      if (!_viewingAll && folder != _currentFolder) {
        await _selectFolder(folder);
      } else {
        _loadSaved();
      }
    } else {
      setState(() => _currentTab = _tabPending);
      _loadPending();
    }
    await _reportUpload(
      folder,
      files.length,
      result.succeeded.length,
      result.errors,
      note: 'File lỗi đã được giữ lại trong Local.',
    );
  }

  Future<void> _openSettings() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => SafeArea(
          // Cuộn được: trên màn hình nhỏ nội dung dài hơn khung bảng.
          child: SingleChildScrollView(
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Cài đặt',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.cloud_upload, color: Colors.blue),
                title: const Text('Đẩy thẳng lên server'),
                subtitle: const Text(
                  'Bật: ảnh/video chụp hoặc chọn từ thư viện được upload ngay '
                  'vào folder chính bên dưới, không lưu vào Local. Nếu upload '
                  'thất bại sẽ được giữ lại trong Local.\n'
                  'Tắt: ảnh lưu vào Local; khi bấm "Lưu server" sẽ đẩy lên '
                  'folder đang chọn.',
                ),
                isThreeLine: true,
                value: _directUpload,
                onChanged: (value) async {
                  await ScreenshotSettings().setDirectUpload(value);
                  setState(() => _directUpload = value);
                  setSheetState(() {});
                },
              ),
              ListTile(
                leading: const Icon(Icons.folder_special, color: Colors.amber),
                title: const Text('Folder chính'),
                subtitle: const Text(
                  'Tự được chọn mỗi khi mở hệ thống, và là nơi nhận ảnh/video '
                  'khi bật "Đẩy thẳng lên server".',
                ),
                isThreeLine: true,
                trailing: DropdownButton<String>(
                  value: _directUploadFolder,
                  items: {..._folders, _directUploadFolder}
                      .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                      .toList(),
                  onChanged: (value) async {
                    if (value == null) return;
                    await ScreenshotSettings().setDirectUploadFolder(value);
                    setState(() => _directUploadFolder = value);
                    setSheetState(() {});
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.bug_report, color: Colors.grey),
                title: const Text('Nhật ký'),
                subtitle: const Text(
                  'Xem và copy nhật ký chọn ảnh/video, thêm vào Local, upload '
                  '(để gửi cho lập trình viên khi gặp lỗi).',
                ),
                isThreeLine: true,
                onTap: () {
                  Navigator.pop(ctx);
                  _showLogDialog();
                },
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  Future<void> _showLogDialog() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nhật ký'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(
              MediaLog.isEmpty ? '(chưa có nhật ký)' : MediaLog.dump(),
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              MediaLog.clear();
              Navigator.pop(ctx);
            },
            child: const Text('Xóa'),
          ),
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: MediaLog.dump()));
              if (ctx.mounted) Navigator.pop(ctx);
              _showSnack('Đã copy nhật ký');
            },
            child: const Text('Copy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  /// Xem trước mục đã lưu trong dialog lớn: ảnh phóng to/thu nhỏ được, video
  /// hiện thumbnail (bấm để phát bằng app xem video của máy). Có Chia sẻ /
  /// Copy link / Đóng.
  void _openSavedPreview(ScreenshotInfo info) {
    final isVideo = _isVideoFile(info.fileName);
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(12),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: FutureBuilder<Uint8List>(
                future: isVideo ? _largeVideoThumbnailFor(info) : _thumbnailFor(info),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const SizedBox(
                      height: 200,
                      child: Center(child: Text('Không tải được ảnh')),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const SizedBox(
                      height: 300,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (!isVideo) {
                    // Khung ảnh chiếm ~70% chiều cao màn hình, có phóng to
                    // để xem rõ từng góc.
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.75,
                      width: double.infinity,
                      child: ZoomableImage(bytes: snapshot.data!),
                    );
                  }
                  final image = Image.memory(
                    snapshot.data!,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  );
                  return GestureDetector(
                    onTap: () => _openSavedVideo(info),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        image,
                        const Icon(
                          Icons.play_circle_fill,
                          color: Colors.white70,
                          size: 72,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                if (!isVideo)
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _openFullImage(info);
                    },
                    icon: const Icon(Icons.fullscreen),
                    label: const Text('Mở full'),
                  ),
                TextButton.icon(
                  onPressed: () => _shareSaved(info),
                  icon: const Icon(Icons.share),
                  label: const Text('Chia sẻ'),
                ),
                TextButton.icon(
                  onPressed: () => _copyLink(info),
                  icon: const Icon(Icons.link),
                  label: const Text('Copy link'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Đóng'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Xem trước ảnh chưa lưu (file local) trong dialog lớn, có phóng to,
  /// Mở full và Chia sẻ.
  Future<void> _openPendingPreview(PendingScreenshot item) async {
    final file = File(item.filePath);
    final Uint8List bytes;
    try {
      bytes = await file.readAsBytes();
    } catch (e) {
      _showSnack('Không mở được ảnh: $e');
      return;
    }
    if (!mounted) return;

    final title = file.uri.pathSegments.last;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(12),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SizedBox(
                height: MediaQuery.of(ctx).size.height * 0.75,
                width: double.infinity,
                child: ZoomableImage(bytes: bytes),
              ),
            ),
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => FullScreenMemoryImageScreen(
                          bytes: bytes,
                          title: title,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.fullscreen),
                  label: const Text('Mở full'),
                ),
                TextButton.icon(
                  onPressed: () => _shareFile(file),
                  icon: const Icon(Icons.share),
                  label: const Text('Chia sẻ'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Đóng'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Mở ảnh đã lưu toàn màn hình (zoom được).
  Future<void> _openFullImage(ScreenshotInfo info) async {
    try {
      final bytes = await _thumbnailFor(info);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              FullScreenMemoryImageScreen(bytes: bytes, title: info.fileName),
        ),
      );
    } catch (e) {
      _showSnack('Không tải được ảnh: $e');
    }
  }

  /// Thumbnail video độ phân giải cao hơn, dùng cho dialog xem trước.
  Future<Uint8List> _largeVideoThumbnailFor(ScreenshotInfo info) {
    return _cachedThumbnail('large_${info.folderName}/${info.fileName}_${info.lastModified}', () async {
      final deviceName = await DeviceNameHelper.current();
      return _service.remoteVideoThumbnail(
        deviceName,
        info.folderName,
        info.fileName,
        token: info.token,
        maxWidth: 720,
      );
    });
  }

  /// Tải mục đã lưu về file tạm (dùng để mở bằng app khác hoặc chia sẻ).
  /// Ảnh dùng lại bytes đã cache từ thumbnail; video tải trực tiếp từ server.
  Future<File> _downloadToTemp(ScreenshotInfo info) async {
    final deviceName = await DeviceNameHelper.current();
    final bytes = _isVideoFile(info.fileName)
        ? await _service.viewScreenshot(
            deviceName,
            info.folderName,
            info.fileName,
            token: info.token,
          )
        : await _thumbnailFor(info);
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/${info.fileName}');
    await tempFile.writeAsBytes(bytes);
    return tempFile;
  }

  /// Hiện hộp thoại tiến trình trong lúc chạy [task], tự đóng khi xong/lỗi.
  Future<T> _withLoading<T>(String message, Future<T> Function() task) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      ),
    );
    try {
      return await task();
    } finally {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)));
  }

  /// Video đã lưu: tải về file tạm rồi mở bằng app xem video mặc định của
  /// máy (không có trình phát video gắn trong app).
  Future<void> _openSavedVideo(ScreenshotInfo info) async {
    try {
      final tempFile = await _withLoading(
        'Đang tải video...',
        () => _downloadToTemp(info),
      );
      final result = await OpenFilex.open(tempFile.path);
      if (result.type != ResultType.done) {
        _showSnack('Không thể mở video: ${result.message}');
      }
    } catch (e) {
      _showSnack('Lỗi khi tải video: $e');
    }
  }

  /// Chia sẻ file qua bảng chia sẻ của hệ điều hành (Zalo, Facebook,
  /// Messenger... tùy app đã cài trên máy).
  Future<void> _shareFile(File file) => _shareFiles([file]);

  Future<void> _shareFiles(List<File> files) async {
    try {
      final box = context.findRenderObject() as RenderBox?;
      await SharePlus.instance.share(
        ShareParams(
          files: [for (final f in files) XFile(f.path)],
          sharePositionOrigin: box != null
              ? (box.localToGlobal(Offset.zero) & box.size)
              : null,
        ),
      );
    } catch (e) {
      _showSnack('Lỗi khi chia sẻ: $e');
    }
  }

  Future<void> _shareSaved(ScreenshotInfo info) async {
    try {
      final tempFile = await _withLoading(
        'Đang chuẩn bị file...',
        () => _downloadToTemp(info),
      );
      if (!mounted) return;
      await _shareFile(tempFile);
    } catch (e) {
      _showSnack('Lỗi khi chia sẻ: $e');
    }
  }

  Future<void> _copyLink(ScreenshotInfo info) => _copyLinks([info]);

  /// Copy link của 1 hoặc nhiều ảnh/video trên server (mỗi link một dòng) vào
  /// clipboard. Link dùng mã (token) do server cấp: không chứa tên người dùng,
  /// folder hay tên file.
  Future<void> _copyLinks(List<ScreenshotInfo> infos) async {
    if (infos.isEmpty) return;
    final withToken = infos.where((i) => i.token.isNotEmpty).toList();
    if (withToken.isEmpty) {
      await _showErrorDialog(
        'Không tạo được link',
        'Server chưa trả mã (token) cho file này. Hãy làm mới danh sách '
            '(kéo xuống) hoặc cập nhật backend rồi thử lại.',
      );
      return;
    }

    final links = withToken.map((i) => _service.publicViewLink(i.token)).join('\n');
    await Clipboard.setData(ClipboardData(text: links));
    final skipped = infos.length - withToken.length;
    _showSnack(
      skipped > 0
          ? 'Đã copy ${withToken.length} link ($skipped file chưa có mã)'
          : (infos.length == 1 ? 'Đã copy link' : 'Đã copy ${infos.length} link'),
    );
  }

  /// Tách tên file thành (tên không đuôi, đuôi file kèm dấu chấm).
  (String, String) _splitNameExt(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex == -1) return (fileName, '');
    return (fileName.substring(0, dotIndex), fileName.substring(dotIndex));
  }

  /// Hỏi tên mới (không gồm đuôi file) qua dialog, trả về null nếu hủy.
  Future<String?> _askNewName(
    String currentNameNoExt, {
    String title = 'Đổi tên ảnh',
    String? hint,
  }) {
    final controller = TextEditingController(text: currentNameNoExt);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: hint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  /// Đổi tên file ảnh đang chờ lưu, giữ nguyên thời điểm chụp ban đầu.
  Future<void> _renamePending(PendingScreenshot item) async {
    final file = File(item.filePath);
    final (currentNameNoExt, ext) = _splitNameExt(file.uri.pathSegments.last);
    final newName = await _askNewName(currentNameNoExt);
    if (newName == null || newName.isEmpty || newName == currentNameNoExt) {
      return;
    }

    try {
      final newPath = '${file.parent.path}/$newName$ext';
      await file.rename(newPath);
      _loadPending();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(behavior: SnackBarBehavior.floating, content: Text('Lỗi đổi tên: $e')));
    }
  }

  /// Đổi tên ảnh đã lưu trên server.
  Future<void> _renameSaved(ScreenshotInfo info) async {
    final (currentNameNoExt, ext) = _splitNameExt(info.fileName);
    final newName = await _askNewName(currentNameNoExt);
    if (newName == null || newName.isEmpty || newName == currentNameNoExt) {
      return;
    }

    final deviceName = await DeviceNameHelper.current();
    final success = await _service.renameScreenshot(
      deviceName,
      info.folderName,
      info.fileName,
      '$newName$ext',
    );
    if (success) _loadSaved();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(behavior: SnackBarBehavior.floating, content: Text(success ? 'Đã đổi tên ảnh' : 'Đổi tên thất bại')),
    );
  }

  /// Xóa ảnh đã lưu trên server (có xác nhận trước khi xóa).
  Future<void> _deleteSaved(ScreenshotInfo info) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa ảnh "${info.fileName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final deviceName = await DeviceNameHelper.current();
    final success = await _service.deleteScreenshot(
      deviceName,
      info.folderName,
      info.fileName,
    );
    if (success) _loadSaved();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(behavior: SnackBarBehavior.floating, content: Text(success ? 'Đã xóa ảnh' : 'Xóa ảnh thất bại')),
    );
  }

  /// Chọn folder để đẩy lên: bật "Đẩy thẳng lên server" thì dùng luôn folder
  /// chính; ngược lại hiện hộp thoại cho người dùng chọn (mặc định là folder
  /// đang xem). Trả về null nếu người dùng hủy.
  Future<String?> _chooseUploadFolder() async {
    if (_directUpload) return _directUploadFolder;
    return FolderPickerHelper.pick(
      context,
      initial: _viewingAll ? _lastRealFolder : _currentFolder,
      knownFolders: _folders,
    );
  }

  Future<void> _uploadPending(PendingScreenshot item) =>
      _uploadPendingItems([item]);

  /// Đẩy các file Local lên server: hỏi chọn thư mục (hoặc dùng folder chính
  /// khi bật đẩy thẳng), hiện tiến độ. File thành công bị xóa khỏi Local, file
  /// lỗi ở lại Local kèm thông báo lý do.
  Future<void> _uploadPendingItems(List<PendingScreenshot> items) async {
    if (items.isEmpty) return;
    final folder = await _chooseUploadFolder();
    if (folder == null) return;

    final result = await _uploadFiles(
      items.map((e) => File(e.filePath)).toList(),
      folder,
    );
    await _pendingStore.removePendingByPaths(
      result.succeeded.map((f) => f.path),
    );
    if (!mounted) return;
    _exitSelection();
    if (result.succeeded.isNotEmpty) {
      await _refreshFolders(); // folder mới (nếu vừa tạo) xuất hiện trong danh sách
      _loadSaved();
    }
    await _reportUpload(
      folder,
      items.length,
      result.succeeded.length,
      result.errors,
      note: 'File lỗi vẫn nằm trong Local.',
    );
  }

  /// Đẩy lần lượt [files] lên [folder] kèm hộp thoại tiến độ (phần trăm theo
  /// số byte đã gửi). Trả về các file thành công và danh sách lỗi.
  Future<({List<File> succeeded, List<String> errors})> _uploadFiles(
    List<File> files,
    String folder,
  ) async {
    final progress = ValueNotifier<_UploadProgress>(
      _UploadProgress(0, files.length, 0, files.first.uri.pathSegments.last),
    );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text('Đang tải lên server'),
          content: ValueListenableBuilder<_UploadProgress>(
            valueListenable: progress,
            builder: (_, p, __) {
              final overall = (p.index + p.fraction) / p.total;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('File ${p.index + 1}/${p.total}'),
                  Text(
                    p.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(value: overall),
                  const SizedBox(height: 6),
                  Text('${(overall * 100).round()}%'),
                  if (p.totalBytes > 0)
                    Text(
                      '${_formatSize(p.sentBytes)} / ${_formatSize(p.totalBytes)}'
                      '${p.bytesPerSecond > 0 ? '  •  ${_formatSize(p.bytesPerSecond.round())}/s' : ''}',
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  const SizedBox(height: 8),
                  const Text(
                    'Giữ màn hình sáng và không thoát app khi đang tải lên.',
                    style: TextStyle(fontSize: 11, color: Colors.black45),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );

    final succeeded = <File>[];
    final errors = <String>[];
    // Giữ màn hình luôn sáng: khóa màn hình/ngủ sẽ làm iOS tạm dừng app và
    // ngắt kết nối giữa chừng, nhất là khi tải video lớn mất nhiều phút.
    try {
      await WakelockPlus.enable();
    } catch (_) {}
    try {
      final deviceName = await DeviceNameHelper.current();
      for (var i = 0; i < files.length; i++) {
        final file = files[i];
        final name = file.uri.pathSegments.last;
        progress.value = _UploadProgress(i, files.length, 0, name);
        final clock = Stopwatch()..start();
        try {
          final result = await _service.uploadScreenshot(
            file,
            deviceName,
            folder,
            onProgress: (sent, total) {
              final fraction = total == 0 ? 0.0 : sent / total;
              // Chỉ cập nhật khi nhích thêm >= 1% để không vẽ lại quá dày.
              if (fraction - progress.value.fraction >= 0.01 || fraction >= 1) {
                final seconds = clock.elapsedMilliseconds / 1000;
                progress.value = _UploadProgress(
                  i,
                  files.length,
                  fraction,
                  name,
                  sentBytes: sent,
                  totalBytes: total,
                  bytesPerSecond: seconds > 0 ? sent / seconds : 0,
                );
              }
            },
          );
          MediaLog.add('Upload $name -> folder $folder: HTTP ${result.statusCode}');
          if (result.ok) {
            succeeded.add(file);
          } else {
            errors.add('$name: ${result.errorMessage}');
          }
        } catch (e) {
          MediaLog.add('Upload $name lỗi: $e');
          errors.add('$name: ${await _describeUploadException(file, e)}');
        }
      }
    } finally {
      try {
        await WakelockPlus.disable();
      } catch (_) {}
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
    }
    return (succeeded: succeeded, errors: errors);
  }

  /// Giải thích lỗi mạng khi upload. Server (Tomcat) thường ngắt kết nối giữa
  /// chừng ("Connection reset", "Broken pipe") thay vì trả lỗi 413 khi file
  /// vượt giới hạn upload, nên gợi ý nguyên nhân đó kèm dung lượng file.
  Future<String> _describeUploadException(File file, Object error) async {
    final text = error.toString();
    final cutOff = text.contains('Connection reset') ||
        text.contains('Broken pipe') ||
        text.contains('Connection closed');
    if (!cutOff) return 'lỗi kết nối ($text)';

    final sizeMb = ((await file.length()) / (1024 * 1024)).toStringAsFixed(1);
    return 'server ngắt kết nối khi đang nhận file ($sizeMb MB). Thường do file '
        'vượt giới hạn upload của server (spring.servlet.multipart.max-file-size '
        '/ max-request-size, hoặc client_max_body_size nếu có nginx).';
  }

  /// Báo kết quả đẩy [total] file lên [folder]; nếu có lỗi thì hiện hộp thoại
  /// liệt kê lý do từng file.
  Future<void> _reportUpload(
    String folder,
    int total,
    int succeeded,
    List<String> errors, {
    String? note,
  }) async {
    if (errors.isEmpty) {
      _showSnack('Đã đẩy $total file lên folder $folder');
      return;
    }
    _showSnack(
      succeeded == 0
          ? 'Đẩy lên server thất bại'
          : 'Đã đẩy $succeeded/$total file lên folder $folder',
    );
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Một số file chưa đẩy được'),
        content: SingleChildScrollView(
          child: Text([...errors, if (note != null) note].join('\n\n')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_selecting && !_searching,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_selecting) {
          _exitSelection();
        } else {
          _stopSearch();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: _selecting
            ? _buildSelectionAppBar()
            : (_searching ? _buildSearchAppBar() : _buildNormalAppBar()),
        body: Column(
          children: [
            // Thư mục chỉ áp dụng cho tab Server; Local là file trên máy.
            if (_currentTab == _tabSaved) ...[
              _buildFolderBar(),
              const Divider(height: 1),
            ],
            QuickFilterBar(
              options: _options,
              onChanged: _updateOptions,
              trailing: IconButton(
                tooltip: 'Chọn nhiều',
                icon: const Icon(Icons.checklist),
                onPressed: _selecting ? null : () => _enterSelection(),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: IndexedStack(
                index: _currentTab,
                children: [_buildSavedTab(), _buildPendingTab()],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _openAddMediaMenu,
          tooltip: 'Chụp ảnh / quay video / chọn từ thư viện',
          shape: const CircleBorder(),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 4,
          child: const Icon(Icons.camera_alt, size: 28),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  AppBar _buildNormalAppBar() {
    return AppBar(
      title: const Text('Hệ thống MediaCloud'),
      titleTextStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      centerTitle: false,
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      actions: [
        IconButton(
          tooltip: 'Tìm kiếm',
          icon: const Icon(Icons.search),
          onPressed: _startSearch,
        ),
        IconButton(
          tooltip: 'Cài đặt',
          icon: const Icon(Icons.settings),
          onPressed: _openSettings,
        ),
        IconButton(
          tooltip: 'Đổi hệ thống',
          icon: const Icon(kChangeSystemIcon, color: kChangeSystemColor),
          onPressed: () => showChangeSystemDialog(context),
        ),
      ],
    );
  }

  AppBar _buildSearchAppBar() {
    return AppBar(
      leading: IconButton(
        tooltip: 'Đóng tìm kiếm',
        icon: const Icon(Icons.arrow_back),
        onPressed: _stopSearch,
      ),
      title: TextField(
        controller: _searchController,
        autofocus: true,
        textInputAction: TextInputAction.search,
        decoration: const InputDecoration(
          hintText: 'Tìm theo tên file...',
          border: InputBorder.none,
        ),
        onChanged: (value) => setState(() => _query = value.trim()),
      ),
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      actions: [
        if (_query.isNotEmpty)
          IconButton(
            tooltip: 'Xóa nội dung tìm',
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              setState(() => _query = '');
            },
          ),
      ],
    );
  }

  AppBar _buildSelectionAppBar() {
    return AppBar(
      leading: IconButton(
        tooltip: 'Thoát chế độ chọn',
        icon: const Icon(Icons.close),
        onPressed: _exitSelection,
      ),
      title: Text('Đã chọn $_selectedCount'),
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      actions: [
        IconButton(
          tooltip: _allSelected ? 'Bỏ chọn tất cả' : 'Chọn tất cả',
          icon: Icon(_allSelected ? Icons.deselect : Icons.select_all),
          onPressed: _toggleSelectAll,
        ),
        if (_currentTab == _tabSaved)
          IconButton(
            tooltip: 'Copy link',
            icon: const Icon(Icons.link),
            color: Colors.teal,
            onPressed: _selectedCount == 0
                ? null
                : () => _copyLinks(
                    _savedItems
                        .where((e) => _selectedSaved.contains(_savedKey(e)))
                        .toList(),
                  ),
          ),
        if (_currentTab == _tabPending) ...[
          IconButton(
            tooltip: 'Đẩy lên server',
            icon: const Icon(Icons.cloud_upload),
            color: Colors.blue,
            onPressed: _selectedCount == 0 ? null : _uploadSelectedPending,
          ),
          IconButton(
            tooltip: 'Chia sẻ',
            icon: const Icon(Icons.share),
            color: Colors.green,
            onPressed: _selectedCount == 0 ? null : _shareSelectedPending,
          ),
        ],
        IconButton(
          tooltip: 'Xóa mục đã chọn',
          icon: const Icon(Icons.delete),
          color: Colors.red,
          onPressed: _selectedCount == 0 ? null : _deleteSelected,
        ),
      ],
    );
  }

  /// Thanh điều hướng dưới: Server — [nút camera nổi, khoét lõm] — Local.
  Widget _buildBottomBar() {
    return BottomAppBar(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      height: 68,
      padding: EdgeInsets.zero,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        children: [
          Expanded(
            child: _buildNavItem(
              icon: Icons.cloud_done_outlined,
              selectedIcon: Icons.cloud_done,
              label: 'Server',
              selected: _currentTab == _tabSaved,
              onTap: () {
                _exitSelection();
                setState(() => _currentTab = _tabSaved);
              },
            ),
          ),
          const SizedBox(width: 80), // chỗ cho nút camera ở giữa
          Expanded(
            child: _buildNavItem(
              icon: Icons.phone_android_outlined,
              selectedIcon: Icons.phone_android,
              label: 'Local',
              badge: _pendingTotal,
              selected: _currentTab == _tabPending,
              onTap: () {
                _exitSelection();
                setState(() => _currentTab = _tabPending);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
    int badge = 0,
  }) {
    final color = selected ? Colors.blue.shade700 : Colors.black54;
    return InkResponse(
      onTap: onTap,
      radius: 40,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Viên thuốc nền xanh nhạt bao quanh icon của tab đang chọn.
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            width: 60,
            height: 30,
            decoration: BoxDecoration(
              color: selected
                  ? Colors.blue.withValues(alpha: 0.14)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Badge(
                isLabelVisible: badge > 0,
                label: Text(badge > 99 ? '99+' : '$badge'),
                child: Icon(selected ? selectedIcon : icon, color: color, size: 24),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Bọc 1 dòng danh sách để vuốt sang trái hiện các tùy chọn (tắt khi đang
  /// ở chế độ chọn nhiều).
  Widget _swipeable({
    required Key key,
    required Widget child,
    required List<Widget> actions,
    double extentRatio = 0.75,
  }) {
    return Slidable(
      key: key,
      enabled: !_selecting,
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: extentRatio,
        children: actions,
      ),
      child: child,
    );
  }

  Widget _swipeAction(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return SlidableAction(
      onPressed: (_) => onTap(),
      backgroundColor: color,
      foregroundColor: Colors.white,
      icon: icon,
      label: label,
    );
  }

  Widget _buildSavedTab() {
    return RefreshIndicator(
      onRefresh: () async => _loadSaved(),
      child: FutureBuilder<List<ScreenshotInfo>>(
        future: _savedFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }
          final all = snapshot.data ?? [];
          final items = _options.apply(
            all.where((e) => _matchesQuery(e.fileName)),
            nameOf: (e) => e.fileName,
            timeOf: (e) => e.lastModifiedDate,
            sizeOf: (e) => e.size,
          );
          _savedItems = items;
          if (all.isEmpty) {
            return const Center(child: Text('Server chưa có ảnh/video nào'));
          }
          if (items.isEmpty) {
            return const Center(child: Text('Không tìm thấy file phù hợp'));
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final info = items[index];
              final isSelected = _selectedSaved.contains(_savedKey(info));
              final tile = ListTile(
                selected: isSelected,
                selectedTileColor: Colors.blue.withValues(alpha: 0.12),
                leading: _buildSavedLeading(info),
                title: Text(
                  info.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                isThreeLine: true,
                subtitle: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text:
                            '${_dateFormat.format(info.lastModifiedDate)}\n${_formatSize(info.size)}',
                      ),
                      // Xem "Tất cả": ghi rõ file thuộc folder nào.
                      if (_viewingAll) ...[
                        const TextSpan(text: '  •  '),
                        const WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Icon(Icons.folder, size: 13, color: Colors.amber),
                        ),
                        TextSpan(text: ' ${info.folderName}'),
                      ],
                    ],
                  ),
                ),
                trailing: _selecting
                    ? Checkbox(
                        value: isSelected,
                        onChanged: (_) => _toggle(_selectedSaved, _savedKey(info)),
                      )
                    : null,
                onTap: _selecting
                    ? () => _toggle(_selectedSaved, _savedKey(info))
                    : () => _openSavedPreview(info),
                onLongPress: _selecting
                    ? null
                    : () => _enterSelection(savedName: _savedKey(info)),
              );
              return _swipeable(
                key: ValueKey('saved_${_savedKey(info)}'),
                child: tile,
                extentRatio: 0.9,
                actions: [
                  _swipeAction(
                    Icons.link,
                    'Copy link',
                    Colors.teal,
                    () => _copyLink(info),
                  ),
                  _swipeAction(
                    Icons.share,
                    'Chia sẻ',
                    Colors.green,
                    () => _shareSaved(info),
                  ),
                  _swipeAction(
                    Icons.edit,
                    'Đổi tên',
                    Colors.orange,
                    () => _renameSaved(info),
                  ),
                  _swipeAction(
                    Icons.delete,
                    'Xóa',
                    Colors.red,
                    () => _deleteSaved(info),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPendingTab() {
    return RefreshIndicator(
      onRefresh: () async => _loadPending(),
      child: FutureBuilder<List<PendingScreenshot>>(
        future: _pendingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final all = snapshot.data ?? [];
          final items = _options.apply(
            all.where(
              (e) => _matchesQuery(File(e.filePath).uri.pathSegments.last),
            ),
            nameOf: (e) => File(e.filePath).uri.pathSegments.last,
            timeOf: (e) => e.capturedAtDate,
            sizeOf: (e) => e.size,
          );
          _pendingItems = items;
          if (all.isEmpty) {
            return const Center(child: Text('Local chưa có ảnh/video nào'));
          }
          if (items.isEmpty) {
            return const Center(child: Text('Không tìm thấy file phù hợp'));
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              final file = File(item.filePath);
              final isVideo = _isVideoFile(file.path);
              final isSelected = _selectedPending.contains(item.filePath);
              final tile = ListTile(
                selected: isSelected,
                selectedTileColor: Colors.blue.withValues(alpha: 0.12),
                leading: isVideo
                    ? _buildThumbnailBox(
                        'local_${file.path}',
                        () => _service.localVideoThumbnail(file.path),
                        isVideo: true,
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.file(
                          file,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          cacheWidth: 96,
                          gaplessPlayback: true,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image_not_supported),
                        ),
                      ),
                title: Text(
                  file.uri.pathSegments.last,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                isThreeLine: true,
                subtitle: Text(
                  '${_dateFormat.format(item.capturedAtDate)}\n${_formatSize(item.size)}',
                ),
                onTap: _selecting
                    ? () => _toggle(_selectedPending, item.filePath)
                    : (isVideo
                          ? () => OpenFilex.open(file.path)
                          : () => _openPendingPreview(item)),
                onLongPress: _selecting
                    ? null
                    : () => _enterSelection(pendingPath: item.filePath),
                trailing: _selecting
                    ? Checkbox(
                        value: isSelected,
                        onChanged: (_) =>
                            _toggle(_selectedPending, item.filePath),
                      )
                    : null,
              );
              return _swipeable(
                key: ValueKey('pending_${item.filePath}'),
                child: tile,
                actions: [
                  _swipeAction(
                    Icons.edit,
                    'Đổi tên',
                    Colors.orange,
                    () => _renamePending(item),
                  ),
                  _swipeAction(
                    Icons.share,
                    'Chia sẻ',
                    Colors.green,
                    () => _shareFile(file),
                  ),
                  _swipeAction(
                    Icons.cloud_upload,
                    'Lưu server',
                    Colors.blue,
                    () => _uploadPending(item),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

/// Tiến độ đang đẩy file thứ [index] (tính từ 0) trong tổng [total] file.
class _UploadProgress {
  final int index;
  final int total;
  final double fraction; // 0..1 của file hiện tại
  final String fileName;
  final int sentBytes; // đã gửi của file hiện tại
  final int totalBytes; // dung lượng file hiện tại
  final double bytesPerSecond; // tốc độ trung bình của file hiện tại

  const _UploadProgress(
    this.index,
    this.total,
    this.fraction,
    this.fileName, {
    this.sentBytes = 0,
    this.totalBytes = 0,
    this.bytesPerSecond = 0,
  });
}
