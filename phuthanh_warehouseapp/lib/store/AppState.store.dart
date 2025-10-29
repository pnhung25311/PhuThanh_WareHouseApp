import 'package:flutter/widgets.dart';

class AppState with ChangeNotifier, WidgetsBindingObserver {
  AppState._internal();

  static final AppState instance = AppState._internal();

  final Map<String, Object?> _store = {};

  /// Gọi 1 lần khi app khởi tạo để đăng ký lifecycle observer
  void init() {
    WidgetsBinding.instance.addObserver(this);
  }

  /// Lấy giá trị theo key, trả về null nếu không có
  T? get<T>(String key) {
    final v = _store[key];
    if (v == null) return null;
    return v as T?;
  }

  /// Gán giá trị
  void set<T>(String key, T value) {
    _store[key] = value;
    notifyListeners();
  }

  /// Xóa key
  void remove(String key) {
    if (_store.containsKey(key)) {
      _store.remove(key);
      notifyListeners();
    }
  }

  /// Xóa tất cả dữ liệu
  void clear() {
    _store.clear();
    notifyListeners();
  }

  /// Kiểm tra tồn tại key
  bool contains(String key) => _store.containsKey(key);

  /// Lifecycle: khi app bị kill/terminate một số nền tảng sẽ chuyển state sang detached
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      // Clear khi app bị kill / detached
      clear();
    }
  }

  /// Hủy observer nếu cần
  void disposeObserver() {
    WidgetsBinding.instance.removeObserver(this);
  }
}