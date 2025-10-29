import 'dart:convert';
// import 'dart:io';

// import 'package:flutter_demo/model/warehouse/WareHouse.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  const ApiClient();

  Future<String> getBaseUrl() async {
    String localIP = 'http://192.168.1.11:8080/api/';
    String puclicIP = 'http://14.224.207.115:8080/api/';
    try {
      final url = Uri.parse('http://checkip.amazonaws.com/');
      final result = await http.get(url);
      // print(result);
      print("AAAA123 "+ result.statusCode.toString());
      if (result.body.trim() == "14.224.207.115" || result.body.trim() == "Unknown") {
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
    return await http.get(url);
  }

  // POST request
  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final baseUrl = await getBaseUrl(); // ✅ Lấy URL async
    final url = Uri.parse('$baseUrl$endpoint');
    print("================================>123");
    print(url);
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
  }

  // PUT request
  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final baseUrl = await getBaseUrl(); // ✅ Lấy URL async
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
  }
}
