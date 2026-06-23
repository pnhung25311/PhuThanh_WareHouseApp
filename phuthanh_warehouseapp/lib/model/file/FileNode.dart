class FileNode {
  final String name;
  final String path;
  final bool folder;
  final int size;
  final String formattedSize; // Nhận "-" hoặc định dạng "53.7 KB" từ API
  final bool hasChildren;
  final int lastModified;     // Timestamp ngày sửa đổi
  final int createdTime;      // Timestamp ngày tạo
  final int childCount;       // Số lượng item con bên trong thư mục
  final bool directory;       // Quyền ghi (canWrite) dựa theo logic cũ của bạn
  
  List<FileNode> children;
  bool isExpanded;

  FileNode({
    required this.name,
    required this.path,
    required this.folder,
    required this.size,
    required this.formattedSize,
    required this.hasChildren,
    required this.lastModified,
    required this.createdTime,
    required this.childCount,
    required this.directory,
    List<FileNode>? children,
    this.isExpanded = false,
  }) : this.children = children ?? [];

  factory FileNode.fromJson(Map<String, dynamic> json) {
    return FileNode(
      name: json['name'] ?? '',
      path: json['path'] ?? '',
      folder: json['folder'] ?? false,
      size: json['size'] ?? 0,
      formattedSize: json['formattedSize'] ?? '-',
      hasChildren: json['hasChildren'] ?? false,
      lastModified: json['lastModified'] ?? 0,
      createdTime: json['createdTime'] ?? 0,
      childCount: json['childCount'] ?? 0,
      directory: json['directory'] ?? false,
      children: (json['children'] as List<dynamic>? ?? [])
          .map((e) => FileNode.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'folder': folder,
      'size': size,
      'formattedSize': formattedSize,
      'hasChildren': hasChildren,
      'lastModified': lastModified,
      'createdTime': createdTime,
      'childCount': childCount,
      'directory': directory,
      'children': children.map((e) => e.toJson()).toList(),
    };
  }
}