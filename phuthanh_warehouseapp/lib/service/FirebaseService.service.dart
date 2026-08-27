// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'dart:convert';

// import 'package:phuthanh_warehouseapp/core/network/api_client.dart';

// class FireBaseService {
//   Future<void> registerFCMToken(int userId) async {
//     FirebaseMessaging messaging = FirebaseMessaging.instance;
//     const apiClient = ApiClient();
//     // xin quyền (iOS cần)
//     await messaging.requestPermission();

//     // lấy token
//     String? token = await messaging.getToken();
//     print("FCM TOKEN = $token");

//     // gửi lên server
//     await apiClient.post(
//       "dynamic/insert/AccountDevices",
//       jsonEncode({"user_id": userId, "fcm_token": token}),
//     );
//   }
// }
