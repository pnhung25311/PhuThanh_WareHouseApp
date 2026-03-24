import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:http/http.dart' as http;
class WebSocketService {
  late StompClient stompClient;

  Future<String> getBaseUrl() async {
    // String localIP = 'http://192.168.1.54:2010/';
    // String puclicIP = 'http://14.224.207.115:2010/';
    String localIP = 'http://192.168.1.11:8080/';
    String puclicIP = 'http://14.224.207.115:8080/';
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

  void connect(Function(Map<String, dynamic>) onMessage) async{
    final baseUrl = await getBaseUrl(); // ✅ Lấy URL async

    stompClient = StompClient(
      config: StompConfig.sockJS(
        url: baseUrl+ 'ws', // ⚠️ đổi IP của bạn
        onConnect: (frame) {
          print("✅ Connected");

          // subscribe kho
          stompClient.subscribe(
            destination: '/topic/department/warehouse',
            callback: (frame) {
              if (frame.body != null) {
                final data = jsonDecode(frame.body!);
                onMessage(data);
              }
            },
          );
        },
        beforeConnect: () async {
          print('⏳ Connecting...');
        },
        onWebSocketError: (error) {
          print("❌ Error: $error");
        },
      ),
    );

    stompClient.activate();
  }

  void disconnect() {
    stompClient.deactivate();
  }
}
