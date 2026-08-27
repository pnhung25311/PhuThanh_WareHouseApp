import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phuthanh_warehouseapp/core/network/api_client.dart';
import 'package:phuthanh_warehouseapp/helper/sharedPreferences.dart';
import 'package:phuthanh_warehouseapp/model/auth/Acount.model.dart';
import 'package:phuthanh_warehouseapp/warehouse/service/Info.service.dart';

class UserProfileScreen extends StatefulWidget {
  final Account account;

  const UserProfileScreen({super.key, required this.account});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  File? imageFile;
  InfoService infoService = InfoService();
  MySharedPreferences mySharedPreferences = MySharedPreferences();
  
  // 🔥 Bước 1: Tạo biến cục bộ để quản lý trạng thái Account thay vì dùng trực tiếp widget.account
  late Account account; 

  @override
  void initState() {
    super.initState();
    account = widget.account; // Khởi tạo giá trị ban đầu từ widget
  }

  /// ================= PICK IMAGE =================
  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Chụp ảnh"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Chọn từ thư viện"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source);

    if (picked != null) {
      File file = File(picked.path);

      setState(() {
        imageFile = file; // preview ngay lập tức hình ảnh vừa chọn
      });

      /// 🚀 UPLOAD
      await _uploadAvatar(file, account.UserName);
    }
  }

  Future<void> _uploadAvatar(File file, String username) async {
    try {
      final response = await ApiClient().postFile(
        "upload/$username",
        file,
      );

      if (response.statusCode == 200) {
        final resBody = await response.stream.bytesToString();
        print("Upload success: $resBody");

        final update = await infoService.upDateAccount(
          account.AccountID.toString(),
          jsonEncode({'Avatar': resBody.toString().trim()}),
        );

        if (update["isSuccess"]) {
          final data = jsonDecode(resBody);
          String newAvatar = data["avatarUrl"];
print(newAvatar);
          // Tạo object mới chứa avatar mới
          final updatedAccount = account.copyWith(Avatar: newAvatar);

          /// ✅ Lưu vào local storage
          await mySharedPreferences.setDataObject(
            "account",
            updatedAccount.toJson(),
          );

          /// ✅ Bước 2: Cập nhật biến trạng thái cục bộ để ép UI render lại dữ liệu mới
          setState(() {
            account = updatedAccount;
            imageFile = null; // Xóa file nháp tạm thời để hiển thị NetworkImage từ link mới hoàn toàn
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Cập nhật avatar thành công")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Cập nhật avatar thất bại")),
          );
        }
      } else {
        print("Upload failed: ${response.statusCode}");
      }
    } catch (e) {
      print("Upload error: $e");
    }
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    // 💡 Bước 3: Bỏ dòng "final account = widget.account;" cũ đi, hệ thống sẽ tự dùng biến `account` ở trên State.

    return Scaffold(
      appBar: AppBar(
        title: const Text("Thông tin cá nhân"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: Colors.blue,
              child: Column(
                children: [
                  /// AVATAR CLICK
                  GestureDetector(
                    onTap: _showImagePicker,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          backgroundImage: imageFile != null
                              ? FileImage(imageFile!)
                              : (account.Avatar.isNotEmpty
                                        ? NetworkImage(account.Avatar)
                                        : null)
                                    as ImageProvider?,
                          child: (imageFile == null && account.Avatar.isEmpty)
                              ? const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.blue,
                                )
                              : null,
                        ),

                        /// ICON CAMERA
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(6),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    account.FullName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            /// INFO
            _buildItem("Username", account.UserName),
            _buildItem("Họ và tên", account.FullName),
            _buildItem("Vai trò", account.Role),
            _buildItem("Trạng thái", account.Status),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: mở màn hình EditProfileScreen
              },
              child: const Text("Chỉnh sửa thông tin"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(String title, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(flex: 5, child: Text(value)),
        ],
      ),
    );
  }
}

