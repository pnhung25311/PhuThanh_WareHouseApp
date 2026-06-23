import 'dart:convert';
import 'package:phuthanh_warehouseapp/model/file/FileNode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MySharedPreferences {
  // ===== Số =====
  Future<void> setDataNumber(String key, double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, value);
  }

  Future<double?> getDataNumber(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(key);
  }

  // ===== Chuỗi =====
  Future<void> setDataString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String?> getDataString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  // ===== Bool =====
  Future<void> setDataBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<bool?> getDataBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  // ===== Object =====
  Future<void> setDataObject(String key, Map<String, dynamic> value) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(value); // Chuyển object → JSON
    await prefs.setString(key, jsonString);
  }

  Future<Map<String, dynamic>?> getDataObject(String key) async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(key);
    if (jsonString == null) return null;
    return jsonDecode(jsonString);
  }

  // ===== Xóa dữ liệu =====
  Future<void> removeData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  // ===== Xóa toàn bộ dữ liệu =====
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ===== List =====

  Future<void> setDataList(String key, List<dynamic> value) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(value);
    await prefs.setString(key, jsonString);
  }

  Future<List<dynamic>?> getDataList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(key);
    if (jsonString == null) return null;
    return jsonDecode(jsonString) as List<dynamic>;
  }

  Future<void> removeList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  // Thêm vào class MySharedPreferences trong file của bạn
  Future<void> saveShortcuts(List<FileNode> shortcuts) async {
    // Chuyển List<FileNode> thành List các Map Json rồi lưu lại
    List<Map<String, dynamic>> jsonList = shortcuts
        .map((e) => e.toJson())
        .toList();
    await setDataList("file_shortcuts", jsonList);
  }

  Future<List<FileNode>> loadShortcuts() async {
    final list = await getDataList("file_shortcuts");
    if (list == null) return [];
    return list
        .map((e) => FileNode.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
