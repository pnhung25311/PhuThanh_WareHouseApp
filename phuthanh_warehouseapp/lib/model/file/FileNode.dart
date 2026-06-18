class FileNode {
  final String name;
  final String path;
  final bool folder;
  final int size;
  final bool hasChildren;
  final bool directory;
  final List<FileNode> children;

  FileNode({
    required this.name,
    required this.path,
    required this.folder,
    required this.size,
    required this.hasChildren,
    required this.directory,
    required this.children,
  });

  factory FileNode.fromJson(Map<String, dynamic> json) {
    return FileNode(
      name: json['name'] ?? '',
      path: json['path'] ?? '',
      folder: json['folder'] ?? false,
      size: json['size'] ?? 0,
      hasChildren: json['hasChildren'] ?? false,
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
      'hasChildren': hasChildren,
      'directory': directory,
      'children': children.map((e) => e.toJson()).toList(),
    };
  }
}