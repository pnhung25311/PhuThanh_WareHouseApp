import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phuthanh_warehouseapp/file/service/TreeviewService.service.dart';
import 'package:phuthanh_warehouseapp/helper/ResponsiveHelper.helper.dart';
import 'package:phuthanh_warehouseapp/helper/sharedPreferences.dart';
import 'package:phuthanh_warehouseapp/model/file/FileNode.dart';
import 'package:phuthanh_warehouseapp/warehouse/components/utils/ResponsiveDrawerScaffold.custom.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

class TreeViewPage extends StatefulWidget {
  const TreeViewPage({super.key});

  @override
  State<TreeViewPage> createState() => _TreeViewPageState();
}

class _TreeViewPageState extends State<TreeViewPage> {
  final Treeviewservice service = Treeviewservice();
  final MySharedPreferences prefs = MySharedPreferences();

  final List<FileNode> _navigationStack = [];
  List<FileNode> _shortcuts = [];

  List<FileNode> _allCurrentItems = [];
  List<FileNode> _filteredItems = [];
  bool _isLoading = true;

  String _currentViewMode = 'main';

  bool _isSearching = false;
  bool _isUploading = false;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _breadcrumbScrollController = ScrollController();
  String accid = "";
  String accPassword = "";

  FileNode? _clipboardItem;
  String _clipboardAction = "";

  @override
  void initState() {
    super.initState();
    _initData();
    _searchController.addListener(_onSearchChanged);
  }

  void _initData() async {
    final acc = await prefs.getDataObject("account");
    final savedShortcuts = await prefs.loadShortcuts();

    if (mounted) {
      setState(() {
        _shortcuts = savedShortcuts;
      });
    }
    _autoCleanCache();
    if (acc != null) {
      if (mounted) {
        setState(() {
          if (acc["AccountID"] != null) {
            accid = acc["AccountID"].toString();
          }
          if (acc["PassWord"] != null) {
            accPassword = acc["PassWord"].toString();
          }
        });
      }

      if (accid.isNotEmpty) {
        _loadDirectory(accid, "");
      }
    } else {
      debugPrint("❌ Không tìm thấy thông tin Account trong SharedPreferences");
    }
  }

  @override
  void dispose() {
    _breadcrumbScrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDirectory(String accId, String path) async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final data = await service.loadChildren(accId, path);
      if (mounted) {
        setState(() {
          _allCurrentItems = data;
          _filteredItems = data;
          if (!_isSearching) {
            _searchController.clear();
          } else {
            _onSearchChanged();
          }
        });
      }
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

    _scrollToEnd();

    final targetPath = _navigationStack.isEmpty
        ? ""
        : _navigationStack.last.path;
    await _loadDirectory(accid, targetPath);
  }

  void _handleBackNavigation() {
    if (_isSearching) {
      setState(() {
        _isSearching = false;
        _searchController.clear();
        _filteredItems = _allCurrentItems;
      });
      return;
    }

    if (_navigationStack.isNotEmpty) {
      setState(() {
        _navigationStack.removeLast();
      });
      _scrollToEnd();

      final parentPath = _navigationStack.isEmpty
          ? ""
          : _navigationStack.last.path;
      _loadDirectory(accid, parentPath);
      return;
    }

    Navigator.pop(context);
  }

  bool _isPickerOpenActive = false;

Future<void> _handlePickAndUploadFile() async {
  if (_isUploading || _isPickerOpenActive) return;

  // Hiển thị một Dialog nhỏ hoặc BottomSheet để người dùng chọn nguồn
  FileType targetType = FileType.any;
  
  final FileType? selectedType = await showModalBottomSheet<FileType>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
    ),
    builder: (BuildContext context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image_rounded, color: Colors.purple),
              title: const Text('Mở Thư viện ảnh (Gallery)'),
              onTap: () => Navigator.pop(context, FileType.image),
            ),
            ListTile(
              leading: const Icon(Icons.folder_open_rounded, color: Colors.orange),
              title: const Text('Mở Quản lý tệp tin (Files)'),
              onTap: () => Navigator.pop(context, FileType.any),
            ),
          ],
        ),
      );
    },
  );

  if (selectedType == null) return;
  targetType = selectedType;

  // Khai báo danh sách chứa các file đã chọn (quy về một mối để xử lý loop phía dưới)
  List<PlatformFile> pickedFiles = [];

  try {
    _isPickerOpenActive = true;
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (targetType == FileType.image) {
      // 📸 TRƯỜNG HỢP 1: Chọn ảnh từ Thư viện (Sử dụng ImagePicker)
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();
      
      if (images.isNotEmpty) {
        for (var xFile in images) {
          // Lấy thông tin dung lượng file
          final int length = await xFile.length();
          
          pickedFiles.add(
            PlatformFile(
              name: xFile.name,
              path: xFile.path,
              size: length,
            ),
          );
        }
      }
    } else {
      // 📁 TRƯỜNG HỢP 2: Chọn tài liệu/tệp tin khác (Giữ nguyên FilePicker cũ)
      FilePickerResult? result = await FilePicker.pickFiles(
        type: targetType,
        allowMultiple: true, 
      );
      if (result != null) {
        pickedFiles = result.files;
      }
    }
  } catch (e) {
    _showErrorSnackBar("Không thể mở cửa sổ chọn file: $e");
    return;
  } finally {
    _isPickerOpenActive = false;
  }

  // ---- Giữ nguyên đoạn code xử lý Loop Upload (for...) phía dưới của bạn ----
  // ⚡ SỬA CHÚT XỈU: Thay vì kiểm tra 'result', ta kiểm tra 'pickedFiles' trực tiếp
  if (pickedFiles.isEmpty) return;
  
  setState(() {
    _isUploading = true;
  });

  int successCount = 0;
  int failCount = 0;
  // Xóa hoặc comment dòng này đi vì ta đã khai báo biến pickedFiles ở trên rồi:
  // final List<PlatformFile> pickedFiles = result.files; 

  try {
    final String currentRemotePath = _navigationStack.isEmpty
        ? ""
        : _navigationStack.last.path;

    for (int i = 0; i < pickedFiles.length; i++) {
      final PlatformFile pickedFile = pickedFiles[i];
      
      if (pickedFile.path == null) {
        failCount++;
        continue;
      }

      if (mounted && pickedFiles.length > 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đang upload tệp (${i + 1}/${pickedFiles.length}): ${pickedFile.name}'),
            duration: const Duration(milliseconds: 800),
          )
        );
      }

      try {
        final File localFile = File(pickedFile.path!);
        
        await service.uploadFile(
          currentRemotePath,
          localFile,
        );
        
        successCount++;
      } catch (e) {
        debugPrint("❌ Lỗi upload file [${pickedFile.name}]: $e");
        failCount++;
      }
    }

    if (failCount == 0) {
      _showSuccessSnackBar('Tải lên thành công toàn bộ $successCount tệp tin!');
    } else {
      _showSuccessSnackBar('Đã tải lên $successCount tệp thành công, thất bại $failCount tệp.');
    }

    await _loadDirectory(accid, currentRemotePath);

  } catch (e) {
    _showErrorSnackBar('Xảy ra lỗi trong quá trình xử lý upload: $e');
  } finally {
    if (mounted) {
      setState(() {
        _isUploading = false;
      });
    }
  }
}
  Future<void> _handleDelete(FileNode item) async {
    final Map<String, dynamic>? result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => DeleteConfirmationDialog(itemName: item.name),
    );

    if (result == null || result['confirm'] != true) return;

    final String enteredPassword = result['password'] ?? '';

    if (enteredPassword.trim().isEmpty) {
      _showErrorSnackBar('Mật khẩu không được để trống!');
      return;
    }

    if (enteredPassword.trim() != accPassword) {
      _showErrorSnackBar('Mật khẩu nhập vào không chính xác!');
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final String successMsg = await service.deleteFileOrFolder(item.path);
      _showSuccessSnackBar(successMsg);

      final String currentRemotePath = _navigationStack.isEmpty
          ? ""
          : _navigationStack.last.path;

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
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getSubtitle(FileNode file) {
    final timestamp = file.lastModified;
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final formatted = DateFormat('dd/MM/yyyy HH:mm:ss').format(dateTime);
    if (file.folder) {
      return "Thư mục ${formatted}";
    }
    String sizeText = (file.formattedSize != "-")
        ? file.formattedSize
        : "Không rõ dung lượng";
    return "$sizeText  •  Last modified";
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
                "Tệp tin",
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
        controller: _breadcrumbScrollController,
        scrollDirection: Axis.horizontal,
        child: Row(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }

  void _scrollToEnd() {
    if (_currentViewMode != 'main') return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_breadcrumbScrollController.hasClients) {
        _breadcrumbScrollController.animateTo(
          _breadcrumbScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildViewModeDropdown() {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _currentViewMode,
        icon: const Icon(
          Icons.arrow_drop_down_rounded,
          color: Colors.black87,
          size: 28,
        ),
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: Colors.black87,
        ),
        dropdownColor: Colors.white,
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              _currentViewMode = newValue;
            });
          }
        },
        items: const [
          DropdownMenuItem(
            value: 'main',
            child: Row(
              children: [
                Icon(Icons.folder_copy_rounded, color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Text("Quản lý tệp tin"),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'shortcuts',
            child: Row(
              children: [
                Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                SizedBox(width: 8),
                Text("Lối tắt"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMainMode = _currentViewMode == 'main';
    final List<FileNode> displayList = isMainMode ? _filteredItems : _shortcuts;

    return PopScope(
      canPop: !_isSearching && _navigationStack.isEmpty,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackNavigation();
      },
      child: ResponsiveDrawerScaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: _navigationStack.isEmpty
              ? (isDesktopLayout(context)
                    ? null
                    : Builder(
                        builder: (context) => IconButton(
                          icon: const Icon(Icons.menu_rounded, color: Colors.black87),
                          tooltip: 'Mở menu',
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                        ),
                      ))
              : IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.black87,
                    size: 20,
                  ),
                  onPressed: _handleBackNavigation,
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
              : _buildViewModeDropdown(),
          actions: [
            if (isMainMode) ...[
              IconButton(
                icon: const Icon(
                  Icons.settings_suggest_rounded,
                  color: Colors.black87,
                ),
                tooltip: 'Cấu hình dọn dẹp',
                onPressed: _showCacheSettingsDialog,
              ),
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
            ],
          ],
          elevation: 0,
          backgroundColor: Colors.white,
          centerTitle: false,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isMainMode) _buildBreadcrumbs(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    isMainMode
                        ? Icons.sort_by_alpha_rounded
                        : Icons.star_outline_rounded,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isMainMode
                        ? (_isSearching
                              ? "Kết quả tìm kiếm (${_filteredItems.length})"
                              : "Danh sách tệp tin")
                        : "Danh sách lối tắt đã lưu (${_shortcuts.length})",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),
            Expanded(
              child: (isMainMode && _isLoading)
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.orange,
                        strokeWidth: 2,
                      ),
                    )
                  : RefreshIndicator(
                      color: Colors.orange,
                      onRefresh: () async {
                        if (isMainMode) {
                          await _loadDirectory(
                            accid,
                            _navigationStack.isEmpty
                                ? ""
                                : _navigationStack.last.path,
                          );
                        } else {
                          final savedShortcuts = await prefs.loadShortcuts();
                          if (mounted) {
                            setState(() {
                              _shortcuts = savedShortcuts;
                            });
                          }
                        }
                      },
                      child: displayList.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.5,
                                  child: Center(
                                    child: Text(
                                      isMainMode
                                          ? (_isSearching
                                                ? "Không tìm thấy kết quả"
                                                : "Thư mục trống")
                                          : "Chưa có mục lối tắt nào được lưu",
                                      style: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: displayList.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(
                                    height: 1,
                                    thickness: 0.5,
                                    indent: 70,
                                  ),
                              itemBuilder: (context, index) {
                                final file = displayList[index];
                                final isFav = _isShortcut(file);

                                return ListTile(
                                  onTap: () => _onItemClickFromList(file),
                                  onLongPress: () => _showFileActionSheet(file),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 6,
                                  ),
                                  leading: file.folder
                                      ? Container(
                                          width: 42,
                                          height: 42,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFF3E0),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Colors.orange.withValues(
                                                alpha: 0.15,
                                              ),
                                              width: 1,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.folder_rounded,
                                            color: Colors.orange,
                                            size: 26,
                                          ),
                                        )
                                      : _buildFilePreview(file.name),
                                  title: Text(
                                    file.name,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      _getSubtitle(file),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(
                                      isFav
                                          ? Icons.star_rounded
                                          : Icons.more_vert_rounded,
                                      color: isFav
                                          ? Colors.amber
                                          : Colors.grey.shade500,
                                      size: 22,
                                    ),
                                    onPressed: () => {
                                      _showFileActionSheet(file),
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
        floatingActionButton: isMainMode
            ? Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_navigationStack.isNotEmpty) ...[
                      if (_clipboardItem != null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            FloatingActionButton.extended(
                              heroTag: "btnPasteAction",
                              onPressed: _isLoading ? null : _handlePasteAction,
                              backgroundColor: Colors.green,
                              icon: const Icon(
                                Icons.paste_rounded,
                                color: Colors.white,
                              ),
                              label: Text(
                                _clipboardAction == 'copy'
                                    ? 'Dán Sao chép'
                                    : 'Dán Di chuyển',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            FloatingActionButton(
                              heroTag: "btnClearClipboard",
                              mini: true,
                              onPressed: () {
                                setState(() {
                                  _clipboardAction = '';
                                  _clipboardItem = null;
                                });
                              },
                              backgroundColor: Colors.redAccent,
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                      ],

                      if (_clipboardItem == null) ...[
                        FloatingActionButton(
                          mini: true,
                          onPressed: () => _showCreateFolderDialog(context),
                          backgroundColor: Colors.blue,
                          child: const Icon(
                            Icons.create_new_folder_rounded,
                            color: Colors.white,
                          ),
                        ),
                        FloatingActionButton(
                          mini: true,
                          heroTag: "btnUploadAction",
                          onPressed: _isUploading
                              ? null
                              : _handlePickAndUploadFile,
                          backgroundColor: _isUploading
                              ? Colors.grey
                              : Colors.orange,
                          tooltip: 'Tải file mới lên thư mục này',
                          child: _isUploading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.cloud_upload_rounded,
                                  color: Colors.white,
                                ),
                        ),
                      ],
                    ],
                  ],
                ),
              )
            : null,
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
    } else if (name.endsWith('.doc') ||
        name.endsWith('.docx') ||
        name.endsWith('.odt')) {
      iconData = Icons.description_rounded;
      mainColor = const Color(0xFF1E88E5);
      bgColor = const Color(0xFFE3F2FD);
    } else if (name.endsWith('.xlsm') ||
        name.endsWith('.xls') ||
        name.endsWith('.xlsx') ||
        name.endsWith('.csv') ||
        name.endsWith('.ods')) {
      iconData = Icons.table_view_rounded;
      mainColor = const Color(0xFF43A047);
      bgColor = const Color(0xFFE8F5E9);
    } else if (name.endsWith('.ppt') ||
        name.endsWith('.pptx') ||
        name.endsWith('.odp')) {
      iconData = Icons.slideshow_rounded;
      mainColor = const Color(0xFFF4511E);
      bgColor = const Color(0xFFFBE9E7);
    } else if (name.endsWith('.txt') ||
        name.endsWith('.log') ||
        name.endsWith('.rtf')) {
      iconData = Icons.article_rounded;
      mainColor = const Color(0xFF78909C);
      bgColor = const Color(0xFFECEFF1);
    } else if (name.endsWith('.png') ||
        name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.webp') ||
        name.endsWith('.gif') ||
        name.endsWith('.bmp')) {
      iconData = Icons.image_rounded;
      mainColor = const Color(0xFF8E24AA);
      bgColor = const Color(0xFFF3E5F5);
    } else if (name.endsWith('.psd') ||
        name.endsWith('.ai') ||
        name.endsWith('.svg') ||
        name.endsWith('.eps')) {
      iconData = Icons.palette_rounded;
      mainColor = const Color(0xFFD81B60);
      bgColor = const Color(0xFFFCE4EC);
    } else if (name.endsWith('.dwg') ||
        name.endsWith('.dxf') ||
        name.endsWith('.step') ||
        name.endsWith('.stp')) {
      iconData = Icons.architecture_rounded;
      mainColor = const Color(0xFF009688);
      bgColor = const Color(0xFFE0F2F1);
    } else if (name.endsWith('.zip') ||
        name.endsWith('.rar') ||
        name.endsWith('.7z') ||
        name.endsWith('.tar') ||
        name.endsWith('.gz')) {
      iconData = Icons.folder_zip_rounded;
      mainColor = const Color(0xFFFFB300);
      bgColor = const Color(0xFFFFF8E1);
    } else if (name.endsWith('.mp4') ||
        name.endsWith('.mkv') ||
        name.endsWith('.avi') ||
        name.endsWith('.mov') ||
        name.endsWith('.wmv') ||
        name.endsWith('.flv')) {
      iconData = Icons.video_collection_rounded;
      mainColor = const Color(0xFF00ACC1);
      bgColor = const Color(0xFFE0F7FA);
    } else if (name.endsWith('.mp3') ||
        name.endsWith('.wav') ||
        name.endsWith('.wma') ||
        name.endsWith('.flac') ||
        name.endsWith('.m4a')) {
      iconData = Icons.audiotrack_rounded;
      mainColor = const Color(0xFF00BCD4);
      bgColor = const Color(0xFFE0F7FA);
    } else if (name.endsWith('.html') ||
        name.endsWith('.css') ||
        name.endsWith('.js') ||
        name.endsWith('.dart') ||
        name.endsWith('.java') ||
        name.endsWith('.py') ||
        name.endsWith('.json') ||
        name.endsWith('.xml') ||
        name.endsWith('.sql')) {
      iconData = Icons.code_rounded;
      mainColor = const Color(0xFF3F51B5);
      bgColor = const Color(0xFFE8EAF6);
    } else if (name.endsWith('.exe') ||
        name.endsWith('.msi') ||
        name.endsWith('.apk') ||
        name.endsWith('.dmg')) {
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
        border: Border.all(color: mainColor.withValues(alpha: 0.15), width: 1),
      ),
      child: Icon(iconData, color: mainColor, size: 22),
    );
  }

  void _onItemClickFromList(FileNode file) {
    if (_currentViewMode == 'main') {
      _onMainItemClick(file);
    } else {
      _onShortcutItemClick(file);
    }
  }

  Future<void> _onMainItemClick(FileNode file) async {
    if (file.folder) {
      setState(() {
        _navigationStack.add(file);
        _isSearching = false;
        _searchController.clear();
      });
      await _loadDirectory(accid, file.path);
      _scrollToEnd();
    } else {
      _handleFileAction(file, actionType: 'open');
    }
  }

  // 🔥 1. HÀM BỔ TRỢ MỚI: Đồng bộ hóa đường dẫn chuẩn cho cả iOS và Android
  Future<String> _getBaseDownloadPath() async {
    if (Platform.isAndroid) {
      // Nhắm thẳng vào bộ nhớ ngoài (External Storage) -> Thư mục Downloads của app
      final List<Directory>? extDirs = await getExternalStorageDirectories(
        type: StorageDirectory.downloads,
      );
      if (extDirs != null && extDirs.isNotEmpty) {
        return "${extDirs.first.path}/PhuThanhDownloads";
      }
    }
    // iOS giữ nguyên cơ chế sandbox hoạt động tốt của bạn
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    return "${appDocDir.path}/PhuThanhDownloads";
  }

  void _showFileActionSheet(FileNode file) async {
    final isFav = _isShortcut(file);
    File? localFileCorresponding;

    // 🔥 SỬA: Đồng bộ hóa cách kiểm tra file tồn tại bằng hàm _getBaseDownloadPath()
    try {
      final String basePath = await _getBaseDownloadPath();
      String cleanRemotePath = _navigationStack.isEmpty
          ? ""
          : _navigationStack.last.path;
      if (cleanRemotePath.startsWith('/')) {
        cleanRemotePath = cleanRemotePath.substring(1);
      }

      final String localFilePath = cleanRemotePath.isEmpty
          ? "$basePath/${file.name}"
          : "$basePath/$cleanRemotePath/${file.name}";

      final File checkFile = File(localFilePath);
      if (await checkFile.exists()) {
        localFileCorresponding = checkFile;
      }
    } catch (e) {
      debugPrint("❌ Lỗi kiểm tra file cục bộ: $e");
    }

    if (!mounted) return;

    final dateTime = DateTime.fromMillisecondsSinceEpoch(file.lastModified);
    final formattedDate = DateFormat('dd/MM/yyyy HH:mm:ss').format(dateTime);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    file.folder
                        ? Container(
                            width: 50,
                            height: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.folder_rounded,
                              color: Colors.orange,
                              size: 30,
                            ),
                          )
                        : SizedBox(
                            width: 50,
                            height: 50,
                            child: Center(child: _buildFilePreview(file.name)),
                          ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            file.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            file.folder
                                ? "Loại: Thư mục hệ thống"
                                : "Loại: Tệp tin",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          if (!file.folder) ...[
                            Text(
                              "Kích thước: ${file.formattedSize != '-' ? file.formattedSize : 'Không rõ dung lượng'}",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 2),
                          ],
                          Text(
                            "Sửa đổi cuối: $formattedDate",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Đường dẫn: ${file.path.isEmpty ? 'Gốc (Root)' : file.path}",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, thickness: 1),

              ListTile(
                leading: Icon(
                  file.folder
                      ? Icons.folder_open_rounded
                      : Icons.open_in_new_rounded,
                  color: Colors.orange,
                ),
                title: Text(file.folder ? 'Mở thư mục' : 'Mở file'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _onItemClickFromList(file);
                },
              ),
              if (!file.folder)
                ListTile(
                  leading: const Icon(
                    Icons.file_download_rounded,
                    color: Colors.green,
                  ),
                  title: const Text('Tải file về máy'),
                  subtitle: Text(
                    'Lưu bản sao vĩnh viễn vào bộ nhớ điện thoại',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                  ),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    _handleDownloadFile(file);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.sync_rounded, color: Colors.teal),
                title: const Text('Đồng bộ file cục bộ lên Server'),
                // subtitle: Text(
                //   'Phát hiện bản sao khả dụng ở bộ nhớ máy',
                //   style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                // ),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  if (localFileCorresponding != null) {
                    _handleSingleFileSync(localFileCorresponding);
                  } else {
                    _showErrorSnackBar(
                      "Không tìm thấy file cục bộ để đồng bộ!",
                    );
                  }
                },
              ),
              if (!file.folder)
                ListTile(
                  leading: const Icon(Icons.share_rounded, color: Colors.blue),
                  title: const Text('Chia sẻ'),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    _handleFileAction(file, actionType: 'share');
                  },
                ),
              ListTile(
                leading: Icon(
                  isFav ? Icons.star_rounded : Icons.star_border_rounded,
                  color: Colors.amber,
                ),
                title: Text(isFav ? 'Xóa khỏi lối tắt' : 'Thêm vào lối tắt'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _toggleShortcut(file);
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.copy_rounded, color: Colors.blue),
                title: const Text('Sao chép (Copy)'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _handleCopyAction(file);
                },
              ),
              ListTile(
                leading: Icon(
                  file.folder ? Icons.folder : Icons.insert_drive_file,
                ),
                title: const Text("Đổi tên"),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _showRenameDialog(context, file);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.content_cut_rounded,
                  color: Colors.amber,
                ),
                title: const Text('Cắt / Di chuyển (Cut)'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _handleCutAction(file);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_forever_rounded,
                  color: Colors.redAccent,
                ),
                title: Text(
                  file.folder ? 'Xóa thư mục' : 'Xóa file',
                  style: const TextStyle(color: Colors.redAccent),
                ),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _handleDelete(file);
                },
              ),
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
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
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
                    : 'Đang tải file về máy: ${file.name}...',
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
      final Directory cacheDir = await getTemporaryDirectory();
      final String cacheDirPath = cacheDir.path;

      final String fullFilePath = "$cacheDirPath/${file.name}";
      final File targetFile = File(fullFilePath);

      await service.downloadFile(file.path, fullFilePath);

      if (await targetFile.exists()) {
        _showSuccessSnackBar('Đã tải tạm thời file: ${file.name}');

        if (!mounted) return;

        if (actionType == 'open') {
          final result = await OpenFilex.open(fullFilePath);

          // DEBUG: Log kết quả lỗi để dễ dàng kiểm soát
          debugPrint("🔥 OpenFilex Result: ${result.type} - ${result.message}");

          if (result.type != ResultType.done && mounted) {
            _showErrorSnackBar('Không thể mở file: ${result.message}');
          }
        } else if (actionType == 'share') {
          final box = context.findRenderObject() as RenderBox?;
          final filesToShare = <XFile>[XFile(fullFilePath, name: file.name)];

          await Share.shareXFiles(
            filesToShare,
            sharePositionOrigin: box != null
                ? (box.localToGlobal(Offset.zero) & box.size)
                : null,
          );
        }
      } else {
        _showErrorSnackBar('Lỗi: File không tồn tại sau khi tải.');
      }
    } catch (e) {
      debugPrint("❌ Lỗi tải vào bộ nhớ cache ($actionType): $e");
      if (mounted) _showErrorSnackBar('Xảy ra lỗi khi xử lý file: $e');
    }
  }

  bool _isShortcut(FileNode item) {
    return _shortcuts.any((element) => element.path == item.path);
  }

  Future<void> _toggleShortcut(FileNode item) async {
    setState(() {
      if (_isShortcut(item)) {
        _shortcuts.removeWhere((element) => element.path == item.path);
        _showSuccessSnackBar("Đã xóa khỏi lối tắt: ${item.name}");
      } else {
        _shortcuts.add(item);
        _showSuccessSnackBar("Đã thêm vào lối tắt: ${item.name}");
      }
    });
    await prefs.saveShortcuts(_shortcuts);
  }

  Future<void> _onShortcutItemClick(FileNode file) async {
    if (file.folder) {
      setState(() {
        _isSearching = false;
        _searchController.clear();
        _navigationStack.clear();
        _navigationStack.add(file);
        if (file.path.isNotEmpty) {
          List<String> pathParts = file.path.split('/');
          pathParts.removeWhere((part) => part.trim().isEmpty);

          String currentAccumulatedPath = "";
          for (int i = 0; i < pathParts.length; i++) {
            if (file.path.startsWith('/')) {
              currentAccumulatedPath += "/${pathParts[i]}";
            } else {
              currentAccumulatedPath += (i == 0)
                  ? pathParts[i]
                  : "/${pathParts[i]}";
            }

            _navigationStack.add(
              FileNode(
                name: pathParts[i],
                path: currentAccumulatedPath,
                folder: true,
                size: 0,
                hasChildren: true,
                directory: true,
                children: [],
                formattedSize: "-",
                lastModified: DateTime.now().millisecondsSinceEpoch,
                createdTime: DateTime.now().millisecondsSinceEpoch,
                childCount: 0,
              ),
            );
          }
        } else {
          _navigationStack.add(file);
        }
        _currentViewMode = 'main';
      });

      await _loadDirectory(accid, file.path);
      _scrollToEnd();
    } else {
      _handleFileAction(file, actionType: 'open');
    }
  }

  Future<void> _handleSingleFileSync(File localFile) async {
    if (_isLoading || _isUploading) return;
    if (!await localFile.exists()) {
      _showErrorSnackBar("File cục bộ không tồn tại trên thiết bị!");
      return;
    }

    if (_navigationStack.isEmpty) {
      _showErrorSnackBar(
        "Vui lòng vào một thư mục/ổ đĩa cụ thể để thực hiện đồng bộ file cục bộ!",
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final String currentRemotePath = _navigationStack.last.path;
      final String fileName = localFile.path.split('/').last;

      debugPrint("🔄 Đang tự động đẩy file đơn lẻ: $fileName lên Server...");

      final String responseMessage = await service.uploadFile(
        currentRemotePath,
        localFile,
      );

      final String lowerResponse = responseMessage.toLowerCase();
      if (lowerResponse.contains("không có quyền") ||
          lowerResponse.contains("denied") ||
          lowerResponse.contains("forbidden") ||
          lowerResponse.contains("chưa đăng nhập")) {
        _showErrorSnackBar("$fileName: $responseMessage");
      } else {
        _showSuccessSnackBar(
          "Đã đồng bộ thành công file: $fileName lên Server!",
        );
      }

      await _loadDirectory(accid, currentRemotePath);
    } catch (uploadError) {
      debugPrint("❌ Lỗi khi upload file đơn lẻ: $uploadError");

      String errorStr = uploadError.toString();
      if (errorStr.contains("403") || errorStr.contains("Forbidden")) {
        errorStr = "Tài khoản không có quyền ghi/upload vào thư mục này (403).";
      } else if (errorStr.contains("401") ||
          errorStr.contains("Unauthorized")) {
        errorStr = "Phiên đăng nhập hết hạn hoặc không hợp lệ (401).";
      }

      _showErrorSnackBar(errorStr);
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _autoCleanCache() async {
    try {
      final double expirationDays =
          await prefs.getDataNumber("cache_expiration_days") ?? 3;
      if (expirationDays <= 0) return;

      final DateTime now = DateTime.now();
      int deletedCount = 0;

      final Directory cacheDir = await getTemporaryDirectory();
      if (await cacheDir.exists()) {
        final List<FileSystemEntity> cacheEntities = cacheDir.listSync(
          recursive: false,
        );
        for (var entity in cacheEntities) {
          if (entity is File) {
            final FileStat stat = await entity.stat();
            if (now.difference(stat.modified).inDays >= expirationDays) {
              await entity.delete();
              deletedCount++;
            }
          }
        }
      }

      // 🔥 SỬA: Đồng bộ hóa dọn dẹp cache bằng hàm _getBaseDownloadPath()
      final String basePath = await _getBaseDownloadPath();
      final Directory downloadDir = Directory(basePath);
      if (await downloadDir.exists()) {
        final List<FileSystemEntity> docEntities = downloadDir.listSync(
          recursive: true,
        );
        for (var entity in docEntities) {
          if (entity is File) {
            final FileStat stat = await entity.stat();
            if (now.difference(stat.modified).inDays >= expirationDays) {
              await entity.delete();
              deletedCount++;
            }
          }
        }
      }

      if (deletedCount > 0) {
        debugPrint(
          "🧹 [Tự động dọn dẹp] Đã xóa $deletedCount file cũ hơn $expirationDays ngày.",
        );
      }
    } catch (e) {
      debugPrint("❌ Lỗi khi tự động dọn dẹp cache: $e");
    }
  }

  void _showCacheSettingsDialog() async {
    double currentDays =
        await prefs.getDataNumber("cache_expiration_days") ?? 3;

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.cleaning_services_rounded, color: Colors.orange),
              SizedBox(width: 8),
              Text('Cài đặt dọn dẹp cache', style: TextStyle(fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hệ thống sẽ tự động xóa các file tải tạm thời (cache) sau một khoảng thời gian nhất định để giải phóng bộ nhớ:',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              StatefulBuilder(
                builder: (context, setDialogState) {
                  return Column(
                    children: [
                      RadioListTile<double>(
                        title: const Text('Sau 1 ngày'),
                        value: 1.0,
                        groupValue: currentDays,
                        activeColor: Colors.orange,
                        onChanged: (val) {
                          if (val != null)
                            setDialogState(() => currentDays = val);
                        },
                      ),
                      RadioListTile<double>(
                        title: const Text('Sau 3 ngày (Khuyên dùng)'),
                        value: 3.0,
                        groupValue: currentDays,
                        activeColor: Colors.orange,
                        onChanged: (val) {
                          if (val != null)
                            setDialogState(() => currentDays = val);
                        },
                      ),
                      RadioListTile<double>(
                        title: const Text('Sau 7 ngày (1 tuần)'),
                        value: 7.0,
                        groupValue: currentDays,
                        activeColor: Colors.orange,
                        onChanged: (val) {
                          if (val != null)
                            setDialogState(() => currentDays = val);
                        },
                      ),
                      RadioListTile<double>(
                        title: const Text('Không bao giờ tự động xóa'),
                        value: 0.0,
                        groupValue: currentDays,
                        activeColor: Colors.orange,
                        onChanged: (val) {
                          if (val != null)
                            setDialogState(() => currentDays = val);
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              icon: const Icon(Icons.delete_sweep_rounded, size: 18),
              label: const Text(
                'Dọn dẹp ngay',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                _cleanCacheImmediately();
              },
            ),
            const SizedBox(width: 8),

            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                await prefs.setDataNumber("cache_expiration_days", currentDays);
                if (mounted) {
                  Navigator.pop(dialogContext);
                  _showSuccessSnackBar(
                    'Đã cập nhật cấu hình dọn dẹp thành công!',
                  );
                  _autoCleanCache();
                }
              },
              child: const Text(
                'Lưu cấu hình',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cleanCacheImmediately() async {
    setState(() {
      _isLoading = true;
    });

    try {
      int deletedCount = 0;

      final Directory cacheDir = await getTemporaryDirectory();
      if (await cacheDir.exists()) {
        final List<FileSystemEntity> cacheEntities = cacheDir.listSync(
          recursive: true,
        );
        for (var entity in cacheEntities) {
          if (entity is File) {
            await entity.delete();
            deletedCount++;
          }
        }
      }

      // 🔥 SỬA: Đồng bộ hóa dọn dẹp cache tức thì bằng hàm _getBaseDownloadPath()
      final String basePath = await _getBaseDownloadPath();
      final Directory downloadDir = Directory(basePath);

      if (await downloadDir.exists()) {
        final List<FileSystemEntity> entities = downloadDir.listSync(
          recursive: true,
        );
        for (var entity in entities) {
          if (entity is File) {
            await entity.delete();
            deletedCount++;
          }
        }
      }

      if (mounted) {
        _showSuccessSnackBar(
          'Dọn dẹp thành công! Đã xóa tổng cộng $deletedCount tệp tin.',
        );
      }
    } catch (e) {
      debugPrint("❌ Lỗi khi dọn dẹp bộ nhớ: $e");
      if (mounted) _showErrorSnackBar('Không thể dọn dẹp bộ nhớ: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 🔥 2. SỬA CHÍNH: Hàm lưu file đã hoạt động trơn tru 100% trên cả Android & iOS
  Future<void> _handleDownloadFile(FileNode file) async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    _showSuccessSnackBar('Đang tiến hành tải file...');

    try {
      // Gọi hàm chuẩn hóa đường dẫn chung
      final String basePath = await _getBaseDownloadPath();

      String currentRemotePath = _navigationStack.isEmpty
          ? ""
          : _navigationStack.last.path;

      if (currentRemotePath.startsWith('/')) {
        currentRemotePath = currentRemotePath.substring(1);
      }

      // Ghép đường dẫn động chuẩn chỉnh
      final String finalDirectoryPath = currentRemotePath.isEmpty
          ? basePath
          : "$basePath/$currentRemotePath";

      // Tạo cấu trúc cây thư mục (Hỗ trợ đệ quy đa tầng thư mục)
      final Directory targetDir = Directory(finalDirectoryPath);
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      String finalFilePath = "$finalDirectoryPath/${file.name}";
      debugPrint("📂 Đường dẫn tải & lưu thực tế: $finalFilePath");

      // Tải dữ liệu và ghi vào máy
      await service.downloadFile(file.path, finalFilePath);

      final File downloadedFile = File(finalFilePath);
      if (await downloadedFile.exists()) {
        _showSuccessSnackBar('Đã tải về thành công!');
      } else {
        _showErrorSnackBar('Lỗi: File không tồn tại sau khi tải.');
      }
    } catch (e) {
      debugPrint("❌ Lỗi tải file: $e");
      _showErrorSnackBar('Không thể tải file: $e');
    }
  }

  void _handleCopyAction(FileNode item) {
    setState(() {
      _clipboardItem = item;
      _clipboardAction = 'copy';
    });
    _showSuccessSnackBar('Đã sao chép vào bộ nhớ tạm: ${item.name}');
  }

  void _handleCutAction(FileNode item) {
    setState(() {
      _clipboardItem = item;
      _clipboardAction = 'cut';
    });
    _showSuccessSnackBar('Đã cắt vào bộ nhớ tạm: ${item.name}');
  }

  Future<void> _handlePasteAction() async {
    if (_clipboardItem == null || _clipboardAction.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final String currentRemotePath = _navigationStack.isEmpty
          ? ""
          : _navigationStack.last.path;

      String resultMsg = "";

      if (_clipboardAction == 'copy') {
        resultMsg = await service.copyFileOrFolder(
          sourcePath: _clipboardItem!.path,
          targetDirectoryPath: currentRemotePath,
        );
      } else if (_clipboardAction == 'cut') {
        resultMsg = await service.moveFileOrFolder(
          sourcePath: _clipboardItem!.path,
          targetDirectoryPath: currentRemotePath,
        );
      }

      _showSuccessSnackBar(
        resultMsg.isNotEmpty ? resultMsg : 'Thao tác thành công!',
      );

      setState(() {
        _clipboardItem = null;
        _clipboardAction = "";
      });

      await _loadDirectory(accid, currentRemotePath);
    } catch (e) {
      _showErrorSnackBar('Thao tác thất bại: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showRenameDialog(BuildContext context, FileNode item) {
    print("DEBUG: Hàm đổi tên đã được kích hoạt cho file: ${item.name}");
    TextEditingController controller = TextEditingController(text: item.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Đổi tên"),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final newName = controller.text;
                await service.renameItem(accid, item.path, newName);

                if (!context.mounted) return;

                Navigator.pop(context);
                final String currentRemotePath = _navigationStack.isEmpty
                    ? ""
                    : _navigationStack.last.path;
                await _loadDirectory(accid, currentRemotePath);
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Lỗi: ${e.toString()}")));
              }
            },
            child: const Text("Lưu"),
          ),
        ],
      ),
    );
  }

  void _showCreateFolderDialog(BuildContext context) {
    final TextEditingController folderNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tạo thư mục mới"),
        content: TextField(
          controller: folderNameController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: "Tên thư mục",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () async {
              final folderName = folderNameController.text.trim();
              if (folderName.isEmpty) return;

              final String currentPath = _navigationStack.isEmpty
                  ? ""
                  : _navigationStack.last.path;

              try {
                await service.createFolder(accid, currentPath, folderName);

                if (!context.mounted) return;
                Navigator.pop(context);

                _loadDirectory(accid, currentPath);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Đã tạo thư mục: $folderName")),
                );
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Lỗi: ${e.toString()}")));
              }
            },
            child: const Text("Tạo"),
          ),
        ],
      ),
    );
  }
}

class DeleteConfirmationDialog extends StatefulWidget {
  final String itemName;
  const DeleteConfirmationDialog({super.key, required this.itemName});

  @override
  State<DeleteConfirmationDialog> createState() =>
      _DeleteConfirmationDialogState();
}

class _DeleteConfirmationDialogState extends State<DeleteConfirmationDialog> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Xác nhận xóa ⚠️'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bạn có chắc chắn muốn xóa "${widget.itemName}" không?\nHành động này không thể hoàn tác!',
            ),
            const SizedBox(height: 16),
            const Text(
              'Vui lòng nhập mật khẩu để xác nhận:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                hintText: 'Nhập mật khẩu của bạn',
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, {
              'confirm': true,
              'password': _passwordController.text,
            });
          },
          child: const Text(
            'Xóa',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
