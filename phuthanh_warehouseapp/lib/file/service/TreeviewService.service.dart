import 'dart:convert';
import 'package:phuthanh_warehouseapp/core/network/api_client.dart';
import 'package:phuthanh_warehouseapp/model/file/FileNode.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:path_provider/path_provider.dart';

class Treeviewservice {
  final ApiClient client = const ApiClient();

  Future<List<FileNode>> LoadTreeview() async {
    try {
      final response = await client.get("file/tree");

      final List data = jsonDecode(response.body);
      print("===============dd");
      print(data);

      return data.map((e) => FileNode.fromJson(e)).toList();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<FileNode>> loadChildren(String path) async {
    final response = await client.get("file/tree?path=$path");

    final List data = jsonDecode(response.body);
    print("===============dd");
    print(data);
    return data.map((e) => FileNode.fromJson(e)).toList();
  }

Future<void> downloadFile(String path, String fileName) async {
  try {
    final response = await client.get("file/download?path=$path");

    if (response.statusCode == 200) {
      final dir = await getApplicationDocumentsDirectory();
      // Dùng p.join để nối đường dẫn an toàn
      final file = File(p.join(dir.path, fileName)); 

      await file.writeAsBytes(response.bodyBytes);
      print("Downloaded: ${file.path}");
    } else {
      // Ép lỗi văng ra ngoài để bên UI (khối try-catch của _handleFileDownloadAndOpen) hứng được và hiện SnackBar cho user biết
      throw Exception("Server trả về lỗi: ${response.statusCode}");
    }
  } catch (e) {
    // Đảm bảo lỗi luôn được đẩy ra ngoài UI
    rethrow; 
  }
}
}
