class FileNode {
  final String name;
  final String path;
  final bool isFolder;
  final List<FileNode> children;

  FileNode({
    required this.name,
    required this.path,
    required this.isFolder,
    required this.children,
  });

  factory FileNode.fromJson(Map<String, dynamic> json) {
    return FileNode(
      name: json['name'],
      path: json['path'],
      isFolder: json['folder'] ?? false,
      children: (json['children'] as List? ?? [])
          .map((e) => FileNode.fromJson(e))
          .toList(),
    );
  }
}
