import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phuthanh_warehouseapp/file/service/TreeviewService.service.dart';
import 'package:phuthanh_warehouseapp/helper/sharedPreferences.dart';
import 'package:phuthanh_warehouseapp/model/file/FileNode.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

class TreeViewPage extends StatefulWidget {
  const TreeViewPage({super.key});

  @override
  State<TreeViewPage> createState() => _TreeViewPageState();
}

class _TreeViewPageState extends State<TreeViewPage> {
  final Treeviewservice service = Treeviewservice();
  final MySharedPreferences prefs = MySharedPreferences();
  
  // Quản lý Stack điều hướng: Thư mục hiện tại nằm ở cuối danh sách
  final List<FileNode> _navigationStack = [];

  List<FileNode> _allCurrentItems = []; // Toàn bộ item của thư mục hiện tại
  List<FileNode> _filteredItems = []; // Item sau khi lọc tìm kiếm
  bool _isLoading = true;

  // Trạng thái cho chức năng Tìm kiếm & Upload
  bool _isSearching = false;
  bool _isUploading = false; 
  final TextEditingController _searchController = TextEditingController();
  String accid = "";

  @override
  void initState() {
    super.initState();
    _initData();
    _searchController.addListener(_onSearchChanged);
  }

  void _initData() async {
    final acc = await prefs.getDataObject("account");
    if (acc != null && acc["AccountID"] != null) {
      setState(() {
        accid = acc["AccountID"].toString();
      });
      _loadDirectory(accid, "");
    } else {
      debugPrint("❌ Không tìm thấy thông tin AccountID trong SharedPreferences");
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Hàm load dữ liệu từ Server
  Future<void> _loadDirectory(String accId, String path) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await service.loadChildren(accId, path);
      setState(() {
        _allCurrentItems = data;
        _filteredItems = data;
        if (!_isSearching) {
          _searchController.clear();
        } else {
          _onSearchChanged();
        }
      });
    } catch (e) {
      debugPrint("Lỗi tải thư mục: $e");
      _showErrorSnackBar('Không thể tải dữ liệu từ Server: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

// ==================== CHỨC NĂNG ĐỒNG BỘ TRUE SYNC (LOCAL -> SERVER) ====================
  Future<void> _handleTrueSync() async {
    if (_isLoading || _isUploading) return;

    if (_navigationStack.isEmpty) {
      _showErrorSnackBar("Vui lòng vào một thư mục/ổ đĩa cụ thể để thực hiện đồng bộ file cục bộ!");
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final baseDir = await getApplicationDocumentsDirectory();
      final String currentRemotePath = _navigationStack.last.path;
      
      String cleanRemotePath = currentRemotePath;
      if (cleanRemotePath.startsWith('/')) cleanRemotePath = cleanRemotePath.substring(1);
      final String localFolderPath = "${baseDir.path}/$cleanRemotePath";
      final Directory localDir = Directory(localFolderPath);

      if (!await localDir.exists()) {
        _showSuccessSnackBar("Thư mục cục bộ trống. Không có file nào cần đồng bộ lên server.");
        return;
      }

      final List<File> localFiles = [];
      try {
        final List<FileSystemEntity> entities = localDir.listSync(recursive: false, followLinks: false);
        for (var entity in entities) {
          if (entity is File) {
            final String name = entity.path.split('/').last;
            if (!name.startsWith('.')) {
              localFiles.add(entity);
            }
          }
        }
      } catch (e) {
        debugPrint("❌ Lỗi khi đọc danh sách file hệ thống local: $e");
      }

      if (localFiles.isEmpty) {
        _showSuccessSnackBar("Không tìm thấy file hợp lệ nào ở bộ nhớ máy để đồng bộ.");
        return;
      }

      final List<String> serverFileNames = _allCurrentItems
          .where((item) => !item.folder)
          .map((item) => item.name.toLowerCase().trim())
          .toList();

      final List<File> filesToUpload = localFiles.where((localFile) {
        final String localFileName = localFile.path.split('/').last.toLowerCase().trim();
        return !serverFileNames.contains(localFileName);
      }).toList();

      if (filesToUpload.isEmpty) {
        _showSuccessSnackBar("Tất cả file cục bộ đã đồng bộ hoàn toàn với Server!");
        return;
      }

      int successCount = 0;
      List<String> errorMessages = []; // Lưu trữ các lỗi xảy ra trong quá trình upload

      for (File file in filesToUpload) {
        final String fileName = file.path.split('/').last;
        debugPrint("🔄 Đang tự động đẩy file: $fileName lên Server...");
        
        try {
          final String responseMessage = await service.uploadFile(currentRemotePath, file);
          
          // Kiểm tra nếu Server không trả về Exception nhưng trả về chuỗi text chứa từ khóa lỗi quyền
          final String lowerResponse = responseMessage.toLowerCase();
          if (lowerResponse.contains("không có quyền") || 
              lowerResponse.contains("denied") || 
              lowerResponse.contains("forbidden") ||
              lowerResponse.contains("chưa đăng nhập")) {
            errorMessages.add("$fileName: $responseMessage");
          } else {
            successCount++;
          }
        } catch (uploadError) {
          debugPrint("❌ Lỗi khi upload file $fileName: $uploadError");
          
          // Chuẩn hóa câu chữ lỗi bóc ra từ Exception (ví dụ: 403 Forbidden)
          String errorStr = uploadError.toString();
          if (errorStr.contains("403") || errorStr.contains("Forbidden")) {
            errorStr = "Tài khoản không có quyền ghi/upload vào thư mục này (403).";
          } else if (errorStr.contains("401") || errorStr.contains("Unauthorized")) {
            errorStr = "Phiên đăng nhập hết hạn hoặc không hợp lệ (401).";
          }
          
          errorMessages.add("$fileName: $errorStr");
        }
      }

      // 6. Biện luận kết quả sau khi kết thúc vòng lặp để đưa ra thông báo chính xác
      await _loadDirectory(accid, currentRemotePath); // Reload lại cây thư mục trước

      if (errorMessages.isNotEmpty) {
        if (successCount == 0) {
          // Trường hợp thất bại hoàn toàn do chặn quyền
          _showErrorSnackBar("Đồng bộ thất bại! Bạn không có quyền upload tệp tin vào đây.");
        } else {
          // Thất bại một phần
          _showErrorSnackBar("Đã đẩy $successCount file. Thất bại ${errorMessages.length} file do lỗi hoặc chặn quyền.");
        }
      } else {
        _showSuccessSnackBar("Đã đồng bộ thành công tất cả ($successCount/${filesToUpload.length}) file lên Server!");
      }

    } catch (e) {
      debugPrint("Lỗi True Sync: $e");
      _showErrorSnackBar("Quá trình đồng bộ xảy ra lỗi: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }
// ===================================================================================

  // Xử lý bộ lọc tìm kiếm
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

  // Bấm vào Breadcrumbs điều hướng nhanh
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

    final targetPath = _navigationStack.isEmpty ? "" : _navigationStack.last.path;
    await _loadDirectory(accid, targetPath);
  }

  // Xử lý nút Back vật lý hoặc trên AppBar
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
      final parentPath = _navigationStack.isEmpty ? "" : _navigationStack.last.path;
      await _loadDirectory(accid, parentPath);
      return false;
    }
    return true;
  }

  bool _isPickerOpenActive = false;

  // Chọn file thủ công bằng tay từ điện thoại đưa lên Server
  Future<void> _handlePickAndUploadFile() async {
    if (_isUploading || _isPickerOpenActive) return;

    FilePickerResult? result;
    try {
      _isPickerOpenActive = true;
      await Future.delayed(const Duration(milliseconds: 300));
      result = await FilePicker.pickFiles(type: FileType.any, allowMultiple: false);
    } catch (e) {
      _showErrorSnackBar("Không thể mở cửa sổ chọn file: $e");
      return;
    } finally {
      _isPickerOpenActive = false;
    }

    if (result == null || result.files.isEmpty || result.files.single.path == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final File localFile = File(result.files.single.path!);
      final String currentRemotePath = _navigationStack.isEmpty ? "" : _navigationStack.last.path;

      final String successMessage = await service.uploadFile(currentRemotePath, localFile);
      _showSuccessSnackBar(successMessage);
      await _loadDirectory(accid, currentRemotePath);
    } catch (e) {
      _showErrorSnackBar('Upload file thất bại: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  // Xóa tệp/thư mục vật lý
  Future<void> _handleDelete(FileNode item) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa ⚠️'),
        content: Text('Bạn có chắc chắn muốn xóa "${item.name}" không?\nHành động này không thể hoàn tác!'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;
    setState(() => _isLoading = true);

    try {
      final String successMsg = await service.deleteFileOrFolder(item.path);
      _showSuccessSnackBar(successMsg);
      final String currentRemotePath = _navigationStack.isEmpty ? "" : _navigationStack.last.path;
      await _loadDirectory(accid, currentRemotePath);
    } catch (e) {
      _showErrorSnackBar('Không thể xóa: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
    );
  }

  String _getSubtitle(FileNode file) {
    final String fakeDate = "Jun 21, 2022 20:56";
    return file.folder ? "$fakeDate  •  Thư mục" : "$fakeDate  •  Mở File";
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
              Icon(Icons.home_filled, color: _navigationStack.isEmpty ? Colors.orange : Colors.grey.shade600, size: 18),
              const SizedBox(width: 4),
              Text(
                "Kho tổng",
                style: TextStyle(
                  color: _navigationStack.isEmpty ? Colors.orange : Colors.grey.shade600,
                  fontWeight: _navigationStack.isEmpty ? FontWeight.bold : FontWeight.normal,
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
      children.add(Icon(Icons.arrow_right_rounded, color: Colors.grey.shade400));
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
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
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
                  _navigationStack.isEmpty ? "Kho dữ liệu Phú Thành" : _navigationStack.last.name,
                  style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 19, color: Colors.black87),
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
            // NÚT BẤM ĐỒNG BỘ: Kích hoạt tính năng so sánh file local -> đẩy lên server
            IconButton(
              icon: _isUploading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange))
                  : const Icon(Icons.sync_rounded, color: Colors.black87),
              tooltip: 'Đồng bộ file từ Mobile lên Server ngay',
              onPressed: (_isLoading || _isUploading) ? null : _handleTrueSync,
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
                  Icon(Icons.sort_by_alpha_rounded, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    _isSearching ? "Kết quả tìm kiếm (${_filteredItems.length})" : "Name",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  if (!_isSearching) Icon(Icons.arrow_upward_rounded, size: 16, color: Colors.grey.shade600),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.orange, strokeWidth: 2))
                  : RefreshIndicator(
                      color: Colors.orange,
                      onRefresh: () => _loadDirectory(accid, _navigationStack.isEmpty ? "" : _navigationStack.last.path),
                      child: _filteredItems.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.5,
                                  child: Center(
                                    child: Text(
                                      _isSearching ? "Không tìm thấy kết quả" : "Thư mục trống",
                                      style: TextStyle(color: Colors.grey.shade400, fontSize: 15),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: _filteredItems.length,
                              separatorBuilder: (context, index) => const Divider(height: 1, thickness: 0.5, indent: 70),
                              itemBuilder: (context, index) {
                                final file = _filteredItems[index];

                                return Dismissible(
                                  key: Key(file.path),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    color: Colors.redAccent,
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20.0),
                                    child: const Icon(Icons.delete_forever, color: Colors.white, size: 28),
                                  ),
                                  confirmDismiss: (direction) async {
                                    _handleDelete(file);
                                    return false;
                                  },
                                  child: ListTile(
                                    onTap: () => _onItemClick(file),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                    leading: file.folder
                                        ? Container(
                                            width: 42,
                                            height: 42,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFF3E0),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: Colors.orange.withOpacity(0.15), width: 1),
                                            ),
                                            child: const Icon(Icons.folder_rounded, color: Colors.orange, size: 24),
                                          )
                                        : _buildFilePreview(file.name),
                                    title: Text(
                                      file.name,
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Colors.black),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(_getSubtitle(file), style: TextStyle(fontSize: 12.5, color: Colors.grey.shade500)),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                                      onPressed: () => _handleDelete(file),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _isUploading ? null : _handlePickAndUploadFile,
          backgroundColor: _isUploading ? Colors.grey : Colors.orange,
          tooltip: 'Tải file mới lên thư mục này',
          child: _isUploading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Icon(Icons.cloud_upload_rounded, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildFilePreview(String fileName) {
    final name = fileName.toLowerCase();
    IconData iconData = Icons.insert_drive_file_rounded;
    Color mainColor = Colors.grey.shade500;
    Color bgColor = Colors.grey.shade100;

    if (name.endsWith('.pdf')) {
      iconData = Icons.picture_as_pdf_rounded;
      mainColor = const Color(0xFFE53935);
      bgColor = const Color(0xFFFFEBEE);
    } else if (name.endsWith('.doc') || name.endsWith('.docx') || name.endsWith('.odt')) {
      iconData = Icons.description_rounded;
      mainColor = const Color(0xFF1E88E5);
      bgColor = const Color(0xFFE3F2FD);
    } else if (name.endsWith('.xlsm') || name.endsWith('.xls') || name.endsWith('.xlsx') || name.endsWith('.csv') || name.endsWith('.ods')) {
      iconData = Icons.table_view_rounded;
      mainColor = const Color(0xFF43A047);
      bgColor = const Color(0xFFE8F5E9);
    } else if (name.endsWith('.ppt') || name.endsWith('.pptx') || name.endsWith('.odp')) {
      iconData = Icons.slideshow_rounded;
      mainColor = const Color(0xFFF4511E);
      bgColor = const Color(0xFFFBE9E7);
    } else if (name.endsWith('.txt') || name.endsWith('.log') || name.endsWith('.rtf')) {
      iconData = Icons.article_rounded;
      mainColor = const Color(0xFF78909C);
      bgColor = const Color(0xFFECEFF1);
    } else if (name.endsWith('.png') || name.endsWith('.jpg') || name.endsWith('.jpeg') || name.endsWith('.webp') || name.endsWith('.gif') || name.endsWith('.bmp')) {
      iconData = Icons.image_rounded;
      mainColor = const Color(0xFF8E24AA);
      bgColor = const Color(0xFFF3E5F5);
    } else if (name.endsWith('.psd') || name.endsWith('.ai') || name.endsWith('.svg') || name.endsWith('.eps')) {
      iconData = Icons.palette_rounded;
      mainColor = const Color(0xFFD81B60);
      bgColor = const Color(0xFFFCE4EC);
    } else if (name.endsWith('.dwg') || name.endsWith('.dxf') || name.endsWith('.step') || name.endsWith('.stp')) {
      iconData = Icons.architecture_rounded;
      mainColor = const Color(0xFF009688);
      bgColor = const Color(0xFFE0F2F1);
    } else if (name.endsWith('.zip') || name.endsWith('.rar') || name.endsWith('.7z') || name.endsWith('.tar') || name.endsWith('.gz')) {
      iconData = Icons.folder_zip_rounded;
      mainColor = const Color(0xFFFFB300);
      bgColor = const Color(0xFFFFF8E1);
    } else if (name.endsWith('.mp4') || name.endsWith('.mkv') || name.endsWith('.avi') || name.endsWith('.mov') || name.endsWith('.wmv') || name.endsWith('.flv')) {
      iconData = Icons.video_collection_rounded;
      mainColor = const Color(0xFF00ACC1);
      bgColor = const Color(0xFFE0F7FA);
    } else if (name.endsWith('.mp3') || name.endsWith('.wav') || name.endsWith('.wma') || name.endsWith('.flac') || name.endsWith('.m4a')) {
      iconData = Icons.audiotrack_rounded;
      mainColor = const Color(0xFF00BCD4);
      bgColor = const Color(0xFFE0F7FA);
    } else if (name.endsWith('.html') || name.endsWith('.css') || name.endsWith('.js') || name.endsWith('.dart') || name.endsWith('.java') || name.endsWith('.py') || name.endsWith('.json') || name.endsWith('.xml') || name.endsWith('.sql')) {
      iconData = Icons.code_rounded;
      mainColor = const Color(0xFF3F51B5);
      bgColor = const Color(0xFFE8EAF6);
    } else if (name.endsWith('.exe') || name.endsWith('.msi') || name.endsWith('.apk') || name.endsWith('.dmg')) {
      iconData = Icons.settings_system_daydream_rounded;
      mainColor = const Color(0xFF455A64);
      bgColor = const Color(0xFFCFD8DC);
    }

    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: mainColor.withOpacity(0.15), width: 1),
      ),
      child: Icon(iconData, color: mainColor, size: 22),
    );
  }

  Future<void> _onItemClick(FileNode file) async {
    if (file.folder) {
      setState(() {
        _navigationStack.add(file);
        _isSearching = false;
        _searchController.clear();
      });
      await _loadDirectory(accid, file.path);
    } else {
      _showFileActionSheet(file);
    }
  }

  void _showFileActionSheet(FileNode file) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(file.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.open_in_new_rounded, color: Colors.orange),
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

  Future<void> _handleFileAction(FileNode file, {required String actionType}) async {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                actionType == 'share' ? 'Đang chuẩn bị chia sẻ file: ${file.name}...' : 'Đang tải file: ${file.name}...',
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );

    try {
      final baseDir = await getApplicationDocumentsDirectory();
      String remotePath = file.path;
      if (remotePath.startsWith('/')) remotePath = remotePath.substring(1);

      final String fullFilePath = "${baseDir.path}/$remotePath";
      await service.downloadFile(file.path, fullFilePath);

      final File targetFile = File(fullFilePath);
      if (await targetFile.exists()) {
        if (actionType == 'open') {
          final result = await OpenFilex.open(fullFilePath);
          if (result.type != ResultType.done && mounted) {
            _showErrorSnackBar('Không tìm thấy ứng dụng phù hợp để mở file này.');
          }
        } else if (actionType == 'share') {
          final box = context.findRenderObject() as RenderBox?;
          final filesToShare = <XFile>[XFile(fullFilePath, name: file.name)];
          await SharePlus.instance.share(
            ShareParams(
              files: filesToShare,
              text: null,
              subject: null,
              sharePositionOrigin: box != null ? (box.localToGlobal(Offset.zero) & box.size) : null,
            ),
          );
        }
      } else {
        _showErrorSnackBar('Lỗi: File không tồn tại sau khi tải về cấu trúc thư mục.');
      }
    } catch (e) {
      debugPrint("❌ Lỗi cấu trúc thư mục & xử lý file ($actionType): $e");
      if (mounted) _showErrorSnackBar('Xảy ra lỗi khi xử lý file: $e');
    }
  }
}