import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/model/newwarehouse/Dmvt.model.dart';

/// Bottom sheet tìm & chọn 1 vật tư trong toàn bộ danh mục (không chỉ những
/// vật tư đã có tồn kho tại 1 kho cụ thể) — dùng cho các màn giao dịch/chuyển
/// kho, vì server tự get-or-create dòng tồn kho khi vật tư lần đầu xuất hiện.
Future<Dmvt?> showMaterialPickerSheet(
  BuildContext context,
  List<Dmvt> materials,
) {
  return showModalBottomSheet<Dmvt>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => _MaterialPickerSheet(materials: materials),
  );
}

class _MaterialPickerSheet extends StatefulWidget {
  final List<Dmvt> materials;

  const _MaterialPickerSheet({required this.materials});

  @override
  State<_MaterialPickerSheet> createState() => _MaterialPickerSheetState();
}

class _MaterialPickerSheetState extends State<_MaterialPickerSheet> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Dmvt> get _filtered {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return widget.materials;
    return widget.materials
        .where((m) => '${m.maVt} ${m.tenVt}'.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        final filtered = _filtered;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chọn vật tư',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'Tìm theo mã hoặc tên vật tư...',
                    prefixIcon: Icon(Icons.search_rounded),
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(
                          child: Text('Không tìm thấy vật tư phù hợp'),
                        )
                      : ListView.separated(
                          controller: scrollController,
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final material = filtered[index];
                            return ListTile(
                              title: Text(
                                material.tenVt.isNotEmpty
                                    ? material.tenVt
                                    : '(Chưa có tên)',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(material.maVt),
                              onTap: () => Navigator.pop(context, material),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
