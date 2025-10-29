import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MySharedPreferences {
  // ===== Chuỗi =====
  static Future<void> setDataString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<String?> getDataString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  // ===== Bool =====
  static Future<void> setDataBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  static Future<bool?> getDataBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  // ===== Object =====
  static Future<void> setDataObject(
    String key,
    Map<String, dynamic> value,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(value); // Chuyển object → JSON
    await prefs.setString(key, jsonString);
  }

  static Future<Map<String, dynamic>?> getDataObject(String key) async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(key);
    if (jsonString == null) return null;
    return jsonDecode(jsonString);
  }

  // ===== Xóa dữ liệu =====
  static Future<void> removeData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  // ===== Xóa toàn bộ dữ liệu =====
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ===== List =====

  static Future<void> setDataList(String key, List<dynamic> value) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(value);
    await prefs.setString(key, jsonString);
  }

  static Future<List<dynamic>?> getDataList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(key);
    if (jsonString == null) return null;
    return jsonDecode(jsonString) as List<dynamic>;
  }

    static Future<void> removeList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
