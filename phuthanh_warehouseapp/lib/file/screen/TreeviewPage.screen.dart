import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phuthanh_warehouseapp/file/service/TreeviewService.service.dart';
import 'package:phuthanh_warehouseapp/model/file/FileNode.dart';
import 'package:share_plus/share_plus.dart';
// 1. THÊM IMPORT FILE_PICKER CHỌN FILE 👇
import 'package:file_picker/file_picker.dart';

class TreeViewPage extends StatefulWidget {
  const TreeViewPage({super.key});

  @override
  State<TreeViewPage> createState() => _TreeViewPageState();
}

class _TreeViewPageState extends State<TreeViewPage> {
  final Treeviewservice service = Treeviewservice();

  // Quản lý Stack điều hướng: Thư mục hiện tại nằm ở cuối danh sách
  final List<FileNode> _navigationStack = [];

  List<FileNode> _allCurrentItems =
      []; // Lưu trữ toàn bộ item của thư mục hiện tại
  List<FileNode> _filteredItems = []; // Lưu trữ item sau khi filter search
  bool _isLoading = true;

  // Trạng thái cho chức năng Search
  bool _isSearching = false;
  bool _isUploading = false; // 👉 THÊM BIẾN NÀY ĐỂ KHÓA RIÊNG CHO TIẾN TRÌNH UPLOAD
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDirectory(""); // Load thư mục gốc ban đầu
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Hàm load dữ liệu của một thư mục cụ thể
  Future<void> _loadDirectory(String path) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await service.loadChildren(path);
      setState(() {
        _allCurrentItems = data;
        _filteredItems = data; // Ban đầu hiển thị toàn bộ
        if (!_isSearching) {
          _searchController.clear();
        } else {
          _onSearchChanged(); // Lọc lại nếu đang giữ trạng thái search
        }
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

  // Xử lý bộ lọc khi gõ tìm kiếm
  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = _allCurrentItems;
      } else {
        _filteredItems = _allCurrentItems.where((file) {
          return file.name.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  // Bấm vào một node trên thanh Breadcrumbs
  Future<void> _onBreadcrumbClick(int index) async {
    setState(() {
      if (index == -1) {
        _navigationStack.clear();
      } else {
        _navigationStack.removeRange(index + 1, _navigationStack.length);
      }
      _isSearching = false;
      _searchController.clear();
    });

    final targetPath = _navigationStack.isEmpty
        ? ""
        : _navigationStack.last.path;
    await _loadDirectory(targetPath);
  }

  // Xử lý khi bấm nút Back (Hệ thống hoặc trên AppBar)
  Future<bool> _onWillPop() async {
    if (_isSearching) {
      setState(() {
        _isSearching = false;
        _searchController.clear();
        _filteredItems = _allCurrentItems;
      });
      return false;
    }

    if (_navigationStack.isNotEmpty) {
      setState(() {
        _navigationStack.removeLast();
      });
      final parentPath = _navigationStack.isEmpty
          ? ""
          : _navigationStack.last.path;
      await _loadDirectory(parentPath);
      return false;
    }
    return true;
  }

  // 2. THÊM HÀM XỬ LÝ CHỌN VÀ UPLOAD FILE LÊN SERVER 👇
  // 1. Tạo một biến cờ để kiểm tra trạng thái khóa (nếu chưa có)
  // Thực tế bạn có thể dùng luôn biến _isLoading đang có sẵn trong file của bạn
// Khai báo một biến local thẳng trong class để khóa luồng mạng (không bị ảnh hưởng bởi quá trình rebuild UI)
// Đảm bảo biến này nằm ở cấp độ thuộc tính của Class State (ngang hàng với _isLoading)
bool _isPickerActive = false; 

  Future<void> _handlePickAndUploadFile() async {
    if (_isPickerActive || _isUploading) {
      debugPrint("Chặn request trùng lặp ngầm!");
      return;
    }

    try {
      _isPickerActive = true; 
      setState(() {
        _isUploading = true;
      });

      // 👉 BƯỚC QUAN TRỌNG NHẤT: Dọn sạch luồng cache Native cũ đang bị kẹt của hệ điều hành
      try {
        await FilePicker.platform.clearTemporaryFiles();
      } catch (e) {
        debugPrint("Không có file tạm cần xóa hoặc plugin chưa khởi tạo: $e");
      }

      // Thêm một khoảng hoãn siêu ngắn (100 mili-giây) để luồng UI và luồng OS đồng bộ với nhau
      await Future.delayed(const Duration(milliseconds: 100));

      // Kích hoạt gọi cửa sổ chọn file từ hệ điều hành kèm Timeout bảo vệ
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false, 
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException("Hệ điều hành phản hồi quá chậm. Vui lòng thử lại!");
        },
      );

      if (result == null || result.files.isEmpty || result.files.single.path == null) {
        debugPrint("Người dùng đã hủy chọn file.");
        _isPickerActive = false; 
        setState(() {
          _isUploading = false;
        });
        return;
      }

      final File localFile = File(result.files.single.path!);
      final String fileName = result.files.single.name;

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đang upload file: $fileName...'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      final String currentRemotePath = _navigationStack.isEmpty ? "" : _navigationStack.last.path;

      // Thực hiện gửi dữ liệu mạng lên Spring Boot Phú Thành
      final String successMessage = await service.uploadFile(currentRemotePath, localFile);

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        _isPickerActive = false; 
        setState(() {
          _isUploading = false;
        });
        
        await _loadDirectory(currentRemotePath);
      }
    } catch (e) {
      debugPrint("Lỗi tiến trình upload: $e");
      _isPickerActive = false; 
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
        if (e is TimeoutException) {
          _showErrorSnackBar('Hệ thống mở thư mục file thất bại. Vui lòng thử lại!');
        } else {
          _showErrorSnackBar('Upload file thất bại: $e');
        }
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

  String _getSubtitle(FileNode file) {
    final String fakeDate = "Jun 21, 2022 20:56";
    if (file.isFolder) {
      return "$fakeDate  •  Thư mục";
    } else {
      return "$fakeDate  •  Mở File";
    }
  }

  Widget _buildBreadcrumbs() {
    List<Widget> children = [];

    children.add(
      InkWell(
        onTap: () => _onBreadcrumbClick(-1),
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.home_filled,
                color: _navigationStack.isEmpty
                    ? Colors.orange
                    : Colors.grey.shade600,
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                "Kho tổng",
                style: TextStyle(
                  color: _navigationStack.isEmpty
                      ? Colors.orange
                      : Colors.grey.shade600,
                  fontWeight: _navigationStack.isEmpty
                      ? FontWeight.bold
                      : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    for (int i = 0; i < _navigationStack.length; i++) {
      final isLast = (i == _navigationStack.length - 1);
      children.add(
        Icon(Icons.arrow_right_rounded, color: Colors.grey.shade400),
      );

      children.add(
        Flexible(
          child: InkWell(
            onTap: () => _onBreadcrumbClick(i),
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                _navigationStack[i].name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isLast ? Colors.orange : Colors.grey.shade600,
                  fontWeight: isLast ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      width: double.infinity,
      color: Colors.grey.shade50,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.black87,
              size: 20,
            ),
            onPressed: () async {
              if (!await _onWillPop()) return;
              if (context.mounted) Navigator.pop(context);
            },
          ),
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  cursorColor: Colors.orange,
                  style: const TextStyle(fontSize: 17, color: Colors.black87),
                  decoration: const InputDecoration(
                    hintText: 'Tìm kiếm file, thư mục...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                )
              : Text(
                  _navigationStack.isEmpty
                      ? "Kho dữ liệu Phú Thành"
                      : _navigationStack.last.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 19,
                    color: Colors.black87,
                  ),
                ),
          actions: [
            _isSearching
                ? IconButton(
                    icon: const Icon(Icons.close, color: Colors.black87),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _isSearching = false;
                        _filteredItems = _allCurrentItems;
                      });
                    },
                  )
                : IconButton(
                    icon: const Icon(Icons.search, color: Colors.black87),
                    onPressed: () {
                      setState(() {
                        _isSearching = true;
                      });
                    },
                  ),
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.black87),
              onPressed: () {},
            ),
          ],
          elevation: 0,
          backgroundColor: Colors.white,
          centerTitle: false,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBreadcrumbs(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.sort_by_alpha_rounded,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isSearching
                        ? "Kết quả tìm kiếm (${_filteredItems.length})"
                        : "Name",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  if (!_isSearching)
                    Icon(
                      Icons.arrow_upward_rounded,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.orange,
                        strokeWidth: 2,
                      ),
                    )
                  : _filteredItems.isEmpty
                  ? Center(
                      child: Text(
                        _isSearching
                            ? "Không tìm thấy kết quả"
                            : "Thư mục trống",
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 15,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _filteredItems.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, thickness: 0.5, indent: 70),
                      itemBuilder: (context, index) {
                        final file = _filteredItems[index];

                        return ListTile(
                          onTap: () => _onItemClick(file),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          leading: file.isFolder
                              ? const Icon(
                                  Icons.folder_rounded,
                                  color: Colors.orange,
                                  size: 42,
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Container(
                                    width: 42,
                                    height: 42,
                                    color: Colors.grey.shade100,
                                    child: _buildFilePreview(file.name),
                                  ),
                                ),
                          title: Text(
                            file.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              _getSubtitle(file),
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),

        // 3. THÊM NÚT FLOATINGACTIONBUTTON CHO HÀNH ĐỘNG UPLOAD FILE 👇
// floatingActionButton: FloatingActionButton(
//           // Bọc trong hàm ẩn danh để đảm bảo Flutter chỉ kích hoạt đúng 1 luồng khi click
//           onPressed: _isUploading 
//               ? null 
//               : () {
//                   _handlePickAndUploadFile();
//                 },
//           backgroundColor: _isUploading ? Colors.grey : Colors.orange,
//           tooltip: 'Tải file mới lên thư mục này',
//           child: _isUploading
//               ? const SizedBox(
//                   width: 24,
//                   height: 24,
//                   child: CircularProgressIndicator(
//                     color: Colors.white,
//                     strokeWidth: 2,
//                   ),
//                 )
//               : const Icon(Icons.cloud_upload_rounded, color: Colors.white),
//         ),
      
      ),
    );
  }

  Widget _buildFilePreview(String fileName) {
    final name = fileName.toLowerCase();

    if (name.endsWith('.pdf')) {
      return const Icon(
        Icons.picture_as_pdf,
        color: Colors.redAccent,
        size: 24,
      );
    }
    if (name.endsWith('.doc') ||
        name.endsWith('.docx') ||
        name.endsWith('.odt')) {
      return const Icon(
        Icons.description_rounded,
        color: Colors.blueAccent,
        size: 24,
      );
    }
    if (name.endsWith('.xls') ||
        name.endsWith('.xlsx') ||
        name.endsWith('.csv')) {
      return const Icon(
        Icons.table_view_rounded,
        color: Colors.green,
        size: 24,
      );
    }
    if (name.endsWith('.ppt') || name.endsWith('.pptx')) {
      return const Icon(
        Icons.slideshow_rounded,
        color: Colors.deepOrange,
        size: 24,
      );
    }
    if (name.endsWith('.txt') || name.endsWith('.md')) {
      return const Icon(
        Icons.article_rounded,
        color: Colors.blueGrey,
        size: 24,
      );
    }

    if (name.endsWith('.mp3') ||
        name.endsWith('.wav') ||
        name.endsWith('.wma') ||
        name.endsWith('.flac') ||
        name.endsWith('.m4a') ||
        name.endsWith('.aac')) {
      return const Icon(Icons.audiotrack_rounded, color: Colors.teal, size: 24);
    }

    if (name.endsWith('.mp4') ||
        name.endsWith('.mkv') ||
        name.endsWith('.avi') ||
        name.endsWith('.mov') ||
        name.endsWith('.flv') ||
        name.endsWith('.wmv')) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.indigo.shade900,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
        ],
      );
    }

    if (name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.png') ||
        name.endsWith('.gif') ||
        name.endsWith('.webp') ||
        name.endsWith('.bmp') ||
        name.endsWith('.svg')) {
      return const Icon(Icons.image_rounded, color: Colors.purple, size: 24);
    }

    if (name.endsWith('.zip') ||
        name.endsWith('.rar') ||
        name.endsWith('.7z') ||
        name.endsWith('.tar') ||
        name.endsWith('.gz')) {
      return const Icon(
        Icons.folder_zip_rounded,
        color: Colors.amber,
        size: 24,
      );
    }

    if (name.endsWith('.html') ||
        name.endsWith('.css') ||
        name.endsWith('.js') ||
        name.endsWith('.ts') ||
        name.endsWith('.dart') ||
        name.endsWith('.json') ||
        name.endsWith('.xml') ||
        name.endsWith('.py') ||
        name.endsWith('.java') ||
        name.endsWith('.cpp')) {
      return const Icon(Icons.code_rounded, color: Colors.cyan, size: 24);
    }

    if (name.endsWith('.apk')) {
      return const Icon(
        Icons.android_rounded,
        color: Colors.lightGreen,
        size: 24,
      );
    }
    if (name.endsWith('.exe') || name.endsWith('.msi')) {
      return const Icon(
        Icons.settings_applications_rounded,
        color: Colors.indigoAccent,
        size: 24,
      );
    }

    return Icon(
      Icons.insert_drive_file_rounded,
      color: Colors.grey.shade400,
      size: 24,
    );
  }

  Future<void> _onItemClick(FileNode file) async {
    if (file.isFolder) {
      setState(() {
        _navigationStack.add(file);
        _isSearching = false;
        _searchController.clear();
      });
      await _loadDirectory(file.path);
    } else {
      _showFileActionSheet(file);
    }
  }

  void _showFileActionSheet(FileNode file) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  file.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(
                  Icons.open_in_new_rounded,
                  color: Colors.orange,
                ),
                title: const Text('Mở file'),
                onTap: () {
                  Navigator.pop(context);
                  _handleFileAction(file, actionType: 'open');
                },
              ),
              ListTile(
                leading: const Icon(Icons.share_rounded, color: Colors.blue),
                title: const Text('Chia sẻ qua ứng dụng khác (Zalo,...)'),
                onTap: () {
                  Navigator.pop(context);
                  _handleFileAction(file, actionType: 'share');
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleFileAction(
    FileNode file, {
    required String actionType,
  }) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                actionType == 'share'
                    ? 'Đang chuẩn bị chia sẻ file: ${file.name}...'
                    : 'Đang tải file: ${file.name}...',
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
        if (actionType == 'open') {
          final result = await OpenFilex.open(fullFilePath);
          if (result.type != ResultType.done && mounted) {
            _showErrorSnackBar(
              'Không tìm thấy ứng dụng phù hợp để mở file này.',
            );
          }
        } else if (actionType == 'share') {
          final box = context.findRenderObject() as RenderBox?;
          final filesToShare = <XFile>[XFile(fullFilePath, name: file.name)];

          await SharePlus.instance.share(
            ShareParams(
              files: filesToShare,
              text: null,
              subject: null,
              sharePositionOrigin: box != null
                  ? (box.localToGlobal(Offset.zero) & box.size)
                  : null,
            ),
          );
        }
      } else {
        _showErrorSnackBar('File không tồn tại sau khi tải về.');
      }
    } catch (e) {
      debugPrint("Lỗi xử lý file ($actionType): $e");
      if (mounted) {
        _showErrorSnackBar('Xảy ra lỗi khi xử lý file: $e');
      }
    }
  }
}
