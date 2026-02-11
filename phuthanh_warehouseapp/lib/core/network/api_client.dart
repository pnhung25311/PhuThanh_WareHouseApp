// import 'dart:convert';
// import 'dart:io';

// import 'package:flutter_demo/model/warehouse/WareHouse.dart';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:phuthanh_warehouseapp/store/AppState.store.dart';

class ApiClient {
  const ApiClient();

  Future<String> getBaseUrl() async {
    // String localIP = 'http://192.168.1.54:2010/api/';
    // String puclicIP = 'http://14.224.207.115:2010/api/';
    String localIP = 'http://192.168.1.11:8080/api/';
    String puclicIP = 'http://14.224.207.115:8080/api/';
    try {
      final url = Uri.parse('http://checkip.amazonaws.com/');
      final result = await http.get(url);
      if (result.body.trim() == "14.224.207.115" ||
          result.body.trim() == "Unknown") {
        return localIP;
      }
      return puclicIP;
    } catch (e) {
      print(e.toString());
      return localIP;
    }
  }

  // GET request
  Future<http.Response> get(String endpoint) async {
    final baseUrl = await getBaseUrl(); // ✅ Lấy URL async
    final url = Uri.parse('$baseUrl$endpoint');
    final token = AppState.instance.get("token");
    print("TOKEN = $token");
    return await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  // POST request
  Future<http.Response> post(String endpoint, String body) async {
    final baseUrl = await getBaseUrl();
    final url = Uri.parse('$baseUrl$endpoint');
    print(url);
    final token = AppState.instance.get("token");

    final headers = {'Content-Type': 'application/json'};

    // ✅ CHỈ GỬI TOKEN KHI CÓ
    if (token != null && token.toString().isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return await http.post(url, headers: headers, body: body);
  }

  // PUT request
  Future<http.Response> put(String endpoint, String body) async {
    final baseUrl = await getBaseUrl(); // ✅ Lấy URL async
    final url = Uri.parse('$baseUrl$endpoint');
    final token = AppState.instance.get("token");
    return await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );
  }

  /// ✅ POST upload file
  Future<http.StreamedResponse> postFile(
    String endpoint,
    File file, {
    Map<String, String>? fields, // optional: gửi thêm form-data text
    String fileField = "file", // tên field upload (backend nhận)
  }) async {
    final baseUrl = await getBaseUrl();
    final url = Uri.parse('$baseUrl$endpoint');
    final token = AppState.instance.get("token");

    final headers = {'Authorization': 'Bearer $token'};
    final request = http.MultipartRequest('POST', url)..headers.addAll(headers);

    // Gửi dữ liệu text (nếu có)
    if (fields != null) {
      request.fields.addAll(fields);
    }

    // Gửi file
    final fileStream = http.MultipartFile.fromBytes(
      fileField,
      await file.readAsBytes(),
      filename: file.path.split('/').last,
    );

    request.files.add(fileStream);

    return await request.send();
  }

  // Delete
  Future<http.Response> delete(String endpoint) async {
    final baseUrl = await getBaseUrl();
    final url = Uri.parse('$baseUrl$endpoint');
    final token = AppState.instance.get("token");

    return await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  // Nếu true → đang nội bộ, dùng IP LAN.
  // Nếu false → đang mạng ngoài, dùng IP public.
  Future<bool> isInternalNetwork() async {
    try {
      final url = Uri.parse('http://checkip.amazonaws.com/');
      final result = await http.get(url);
      final publicIP = result.body.trim();

      print(publicIP == "14.224.207.115");
      print(publicIP == "14.224.207.115");

      // Nếu IP public khác IP server public thì nghĩa là đang LAN
      return publicIP == "14.224.207.115";
    } catch (e) {
      // Lỗi mạng, coi như nội bộ
      return false;
    }
  }
}
