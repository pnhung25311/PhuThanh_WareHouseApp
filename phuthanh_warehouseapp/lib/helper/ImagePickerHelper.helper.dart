import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:phuthanh_warehouseapp/Screen/WareHouse/ViewImgWareHouse.screen.dart';
// import 'package:phuthanh_warehouseapp/model/warehouse/WareHouse.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phuthanh_warehouseapp/core/network/api_client.dart';
import 'package:phuthanh_warehouseapp/helper/FunctionConvertHelper.helper.dart';
import 'package:phuthanh_warehouseapp/warehouse/service/SftpService.service.dart';
import 'package:phuthanh_warehouseapp/warehouse/store/AppState.store.dart';

class ImagePickerHelper {
  final SftpService _sftpService = SftpService();
  ApiClient api = new ApiClient();
  FunctionConvertHelper functionConvertHelper = FunctionConvertHelper();
  Future<bool> get statusConnect async {
    // print();
    return await api.isInternalNetwork();
  }
  // Chọn ảnh từ camera hoặc gallery

  Future<File?> pickImage(
    BuildContext context, {
    bool fromCamera = false,
    required String nameImg,
  }) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 90,
    );

    if (picked == null) return null;

    // File tạm được ImagePicker tạo ra
    final tempFile = File(picked.path);

    // 📁 Lấy thư mục cha (nơi ảnh được lưu tạm)
    final dir = tempFile.parent.path;

    // 🏷️ Đặt tên file mới (VD: product_123_1729958810.jpg)
    final newFileName = "${nameImg}.jpg";

    // 🔗 Tạo đường dẫn mới (ghép tay mà không cần package 'path')
    final newPath = "$dir/$newFileName";

    // 🪄 Copy file sang file mới
    final renamedFile = await tempFile.copy(newPath);

    return renamedFile;
  }

  // Upload ảnh lên server
  Future<String?> uploadImage(File imageFile, String productID) async {
    try {
      return await _sftpService.uploadFile(imageFile, productID);
    } catch (e) {
      debugPrint("⚠️ Lỗi upload ảnh: $e");
      return "";
    }
  }

  Future<String?> uploadImageGuarantee(File imageFile, String productID) async {
    try {
      return await _sftpService.uploadFileGuarantee(imageFile, productID);
    } catch (e) {
      debugPrint("⚠️ Lỗi upload ảnh: $e");
      return "";
    }
  }

  // Xóa ảnh từ server
  Future<bool> deleteImage(String imagePath, String productID) async {
    final fileName = imagePath.split('/').last;
    try {
      return await _sftpService.deleteFile(fileName, productID);
    } catch (e) {
      debugPrint("⚠️ Lỗi xóa ảnh: $e");
      return false;
    }
  }

  Future<bool> deleteImageGuarantee(String imagePath, String productID) async {
    final fileName = imagePath.split('/').last;
    try {
      return await _sftpService.deleteFileGuarantee(fileName, productID);
    } catch (e) {
      debugPrint("⚠️ Lỗi xóa ảnh: $e");
      return false;
    }
  }

  // Hiển thị dialog xem ảnh được lưu trong store theo productID
  // Hiển thị dialog xem ảnh được lưu trong store hoặc link
  Future<void> showStoredImageDialog(
    BuildContext context,
    String nameImg, {
    String? imageUrl, // 🆕 thêm tham số để truyền link ảnh
    required ValueChanged<String?> onImageChanged,
  }) async {
    final file = AppState.instance.get<File?>(nameImg);
    bool isInternal = await statusConnect;
    print("object" + isInternal.toString());
    print(file.toString() + "=====");

    if (file == null && (imageUrl == null || imageUrl.isEmpty)) {
      // Không có ảnh nào
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Không có ảnh"),
          content: const Text("Chưa có ảnh để hiển thị."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Đóng"),
            ),
          ],
        ),
      );
      return;
    }
    print(imageUrl);
    final imgLoad = isInternal
        ? imageUrl!
        : functionConvertHelper.convertToPublicIP(imageUrl!);
    print(imgLoad);

    await showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: file != null
                  ? Image.file(file, fit: BoxFit.contain)
                  : Image.network(
                      // imageUrl!,
                      // isInternal
                      //     ? imageUrl!
                      //     : functionConvertHelper.convertToPublicIP(imageUrl!),
                      imgLoad.trim(),
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const SizedBox(
                          height: 200,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        print("Image failed: $imgLoad");
                        print("Error: $error");
                        print("Stack: $stackTrace");
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Icon(
                            Icons.broken_image,
                            size: 100,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close),
                    label: const Text("Đóng"),
                  ),
                  const SizedBox(width: 8),
                  // TextButton.icon(
                  //   onPressed: () {
                  //     AppState.instance.remove(nameImg);
                  //     onImageChanged(null);
                  //     Navigator.pop(ctx);
                  //   },
                  //   icon: const Icon(Icons.delete, color: Colors.redAccent),
                  //   label: const Text("Xóa ảnh"),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hiển thị BottomSheet chọn hành động ảnh
  Future<void> showImageOptions({
    required BuildContext context,
    required String? currentImageUrl,
    required String productID,
    required ValueChanged<String?> onImageChanged,
    // required WareHouse wh,
    required String nameImg,
    required bool isUpdate,
  }) async {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children:
              currentImageUrl != null && currentImageUrl.isNotEmpty || !isUpdate
              ? [
                  // Đã có ảnh → chỉ hiện xem và xóa
                  ListTile(
                    leading: const Icon(Icons.image, color: Colors.blue),
                    title: const Text('Xem ảnh'),
                    onTap: () async {
                      Navigator.pop(ctx); // đóng bottom sheet trước
                      await showStoredImageDialog(
                        context,
                        nameImg,
                        onImageChanged: onImageChanged,
                        imageUrl: currentImageUrl,
                      );
                    },
                  ),
                  if (isUpdate)
                    ListTile(
                      leading: const Icon(
                        Icons.delete,
                        color: Colors.redAccent,
                      ),
                      title: const Text('Xóa ảnh hiện tại'),
                      onTap: () async {
                        Navigator.pop(ctx);
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (dctx) => AlertDialog(
                            title: const Text("Xác nhận xóa ảnh"),
                            content: const Text(
                              "Bạn có chắc muốn xóa ảnh này?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dctx, false),
                                child: const Text("Hủy"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(dctx, true),
                                child: const Text("Xóa"),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          // final success = await deleteImage(
                          //   currentImageUrl.toString(),
                          //   productID,
                          // );
                          // if (success)
                          onImageChanged(null);
                        }
                      },
                    ),
                ]
              : [
                  // Chưa có ảnh → chỉ hiện chọn mới
                  if (isUpdate)
                    ListTile(
                      leading: const Icon(Icons.photo_library),
                      title: const Text('Chọn ảnh từ thư viện'),
                      onTap: () async {
                        final file = await pickImage(
                          context,
                          fromCamera: false,
                          nameImg: nameImg,
                        );
                        if (file != null) {
                          AppState.instance.set(nameImg, file);
                          // final url = await uploadImage(file, productID);
                          // if (url != null) onImageChanged(url);
                          onImageChanged(file.path);
                        }
                        Navigator.pop(ctx);
                      },
                    ),
                  if (isUpdate)
                    ListTile(
                      leading: const Icon(Icons.camera_alt),
                      title: const Text('Chụp ảnh mới'),
                      onTap: () async {
                        final file = await pickImage(
                          context,
                          fromCamera: true,
                          nameImg: nameImg,
                        );
                        if (file != null) {
                          AppState.instance.set(nameImg, file);
                          onImageChanged(file.path);
                        }
                        Navigator.pop(ctx);
                      },
                    ),
                ],
        ),
      ),
    );
  }
}
