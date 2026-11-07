import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/service/ScreenshotService.service.dart';

/// Hộp thoại chọn thư mục (folder) để đẩy ảnh/video lên server. Có thể chọn
/// folder sẵn có hoặc tạo folder mới (server tự tạo khi upload). Trả về tên
/// folder, hoặc null nếu hủy.
class FolderPickerDialog extends StatefulWidget {
  final List<String> folders;
  final String initial;

  const FolderPickerDialog({
    super.key,
    required this.folders,
    required this.initial,
  });

  @override
  State<FolderPickerDialog> createState() => _FolderPickerDialogState();
}

class _FolderPickerDialogState extends State<FolderPickerDialog> {
  late final List<String> _folders = [...widget.folders];
  late String _selected = widget.initial;

  Future<void> _createFolder() async {
    final controller = TextEditingController();
    final input = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tạo folder mới'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Tên folder'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
    if (input == null || input.isEmpty) return;

    final name = ScreenshotService.sanitizeFolderName(input);
    setState(() {
      if (!_folders.contains(name)) _folders.add(name);
      _selected = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Chọn thư mục để lưu'),
      contentPadding: const EdgeInsets.only(top: 12),
      content: SizedBox(
        width: double.maxFinite,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          child: RadioGroup<String>(
            groupValue: _selected,
            onChanged: (value) => setState(() => _selected = value!),
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final folder in _folders)
                  RadioListTile<String>(
                    value: folder,
                    secondary: const Icon(Icons.folder, color: Colors.amber),
                    title: Text(folder, overflow: TextOverflow.ellipsis),
                  ),
                ListTile(
                  leading: const Icon(
                    Icons.create_new_folder,
                    color: Colors.blue,
                  ),
                  title: const Text(
                    'Tạo folder mới...',
                    style: TextStyle(color: Colors.blue),
                  ),
                  onTap: _createFolder,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _selected),
          child: const Text('Đẩy lên'),
        ),
      ],
    );
  }
}
