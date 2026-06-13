import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phuthanh_warehouseapp/file/service/TreeviewService.service.dart';
import 'package:phuthanh_warehouseapp/model/file/FileNode.dart';

class TreeViewPage extends StatefulWidget {
  const TreeViewPage({super.key});

  @override
  State<TreeViewPage> createState() => _TreeViewPageState();
}

class _TreeViewPageState extends State<TreeViewPage> {
  final Treeviewservice service = Treeviewservice();
  
  // Quản lý Stack điều hướng: Thư mục hiện tại nằm ở cuối danh sách
  final List<FileNode> _navigationStack = [];
  
  List<FileNode> _currentItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDirectory(""); // Load thư mục gốc ban đầu
  }

  // Hàm load dữ liệu của một thư mục cụ thể
  Future<void> _loadDirectory(String path) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await service.loadChildren(path);
      setState(() {
        _currentItems = data;
      });
    } catch (e) {
      debugPrint("Lỗi tải thư mục: $e");
      _showErrorSnackBar('Không thể tải dữ liệu: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Xử lý khi nhấn vào một Item
  Future<void> _onItemClick(FileNode file) async {
    if (file.isFolder) {
      // Nếu là Thư mục: Thêm vào stack điều hướng và nhảy vào trong
      setState(() {
        _navigationStack.add(file);
      });
      await _loadDirectory(file.path);
    } else {
      // Nếu là File: Tiến hành tải và mở file
      await _handleFileDownloadAndOpen(file);
    }
  }

  // Xử lý khi bấm nút Back (Hệ thống hoặc trên AppBar)
  Future<bool> _onWillPop() async {
    if (_navigationStack.isNotEmpty) {
      setState(() {
        _navigationStack.removeLast();
      });
      final parentPath = _navigationStack.isEmpty ? "" : _navigationStack.last.path;
      await _loadDirectory(parentPath);
      return false; // Ngăn không cho thoát màn hình chính
    }
    return true; // Thoát màn hình nếu đang ở thư mục gốc
  }

  Future<void> _handleFileDownloadAndOpen(FileNode file) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Đang tải file: ${file.name}...',
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );

    try {
      await service.downloadFile(file.path, file.name);

      final dir = await getApplicationDocumentsDirectory();
      final String fullFilePath = "${dir.path}/${file.name}";

      if (await File(fullFilePath).exists()) {
        final result = await OpenFilex.open(fullFilePath);

        if (result.type != ResultType.done && mounted) {
          _showErrorSnackBar('Không tìm thấy ứng dụng phù hợp để mở file này.');
        }
      }
    } catch (e) {
      debugPrint("Lỗi xử lý file: $e");
      if (mounted) {
        _showErrorSnackBar('Xảy ra lỗi khi mở file: $e');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // Định dạng hiển thị Subtitle chuẩn xác theo ảnh mẫu
  String _getSubtitle(FileNode file) {
    // Layout mong muốn: "Tháng Chữ_Ngày, Năm Giờ:Phút  •  X items/X MB"
    // Lưu ý: Nếu FileNode của bạn có trường `updatedAt` hay `size/itemCount` thì thay vào đây.
    // Dưới đây tôi hardcode fake data giống hệt ảnh mẫu để bạn dễ hình dung format.
    final String fakeDate = "Jun 21, 2022 20:56"; 
    
    if (file.isFolder) {
      return "$fakeDate  •  1 item"; 
    } else {
      final extension = file.name.split('.').last.toUpperCase();
      return "$fakeDate  •  1.19 MB";
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white, // Ảnh gốc dùng nền trắng tinh
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
            onPressed: () async {
              if (!await _onWillPop()) return;
              if (context.mounted) Navigator.pop(context);
            },
          ),
          title: const Text(
            "Download", // Tên folder hiện tại (hoặc "Kho dữ liệu Phú Thành")
            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 19, color: Colors.black87),
          ),
          actions: [
            IconButton(icon: const Icon(Icons.search, color: Colors.black87), onPressed: () {}),
            IconButton(icon: const Icon(Icons.more_vert, color: Colors.black87), onPressed: () {}),
          ],
          elevation: 0,
          backgroundColor: Colors.white,
          centerTitle: false, // Ảnh gốc căn trái tiêu đề
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumbs: Thanh hiển thị đường dẫn thư mục hiện tại (Internal storage > Download)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.home_filled, color: Colors.grey.shade600, size: 20),
                  Icon(Icons.arrow_right_rounded, color: Colors.grey.shade400),
                  Text("Internal storage", style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                  Icon(Icons.arrow_right_rounded, color: Colors.grey.shade400),
                  const Text("Download", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600, fontSize: 14)),
                ],
              ),
            ),
            
            // Thanh Sort (Name ↕)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.sort_by_alpha_rounded, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text("Name", style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                  Icon(Icons.arrow_upward_rounded, size: 16, color: Colors.grey.shade600),
                ],
              ),
            ),
            
            // Nội dung danh sách file/folder
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.orange, strokeWidth: 2))
                  : _currentItems.isEmpty
                      ? Center(child: Text("Thư mục trống", style: TextStyle(color: Colors.grey.shade400)))
                      : ListView.separated(
                          itemCount: _currentItems.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 4), // Khoảng cách nhỏ giữa các dòng
                          itemBuilder: (context, index) {
                            final file = _currentItems[index];
                            
                            return ListTile(
                              onTap: () => _onItemClick(file),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              leading: file.isFolder
                                  ? const Icon(
                                      Icons.folder_rounded,
                                      color: Colors.orange, // Màu icon thư mục chuẩn Samsung/Android
                                      size: 44,
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: Container(
                                        width: 44,
                                        height: 44,
                                        color: Colors.grey.shade100,
                                        child: _buildFilePreview(file.name),
                                      ),
                                    ),
                              title: Text(
                                file.name,
                                style: const TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  _getSubtitle(file),
                                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // Hàm sinh Preview nhỏ cho File (như ảnh thu nhỏ của video/ảnh hoặc Icon PDF)
  Widget _buildFilePreview(String fileName) {
    final name = fileName.toLowerCase();
    if (name.endsWith('.pdf')) {
      return const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 24);
    }
    if (name.endsWith('.mp4') || name.endsWith('.mkv')) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(color: Colors.indigo.shade900), // Background giả lập thumbnail video
          const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
        ],
      );
    }
    return Icon(Icons.insert_drive_file_rounded, color: Colors.grey.shade400, size: 24);
  }
}