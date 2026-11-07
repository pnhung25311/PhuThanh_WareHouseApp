import 'dart:io';

import 'package:excel/excel.dart' as xls;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/model/newwarehouse/Dmvt.model.dart';
import 'package:phuthanh_warehouseapp/newwarehouse/service/DmvtService.service.dart';

const Color _kPrimaryColor = Color(0xFF0E6B6B);

const List<String> _kExpectedHeaders = [
  'maVt',
  'tenVt',
  'dvt',
  'danhDiemg',
  'danhDiemdd',
  'danhDiemc',
  'thongSo',
  'hangSx',
  'ncSx',
  'ncc',
  'hangXe',
  'dongXe',
  'hsCode',
  'ghiChu',
];

class _PreviewRow {
  final int rowNumber;
  final Dmvt material;
  final List<String> errors;

  _PreviewRow({
    required this.rowNumber,
    required this.material,
    required this.errors,
  });

  bool get isValid => errors.isEmpty;
}

/// Đọc file Excel trên thiết bị, hiển thị preview (kèm lỗi từng dòng) trước
/// khi người dùng xác nhận gửi lên `POST /api/materials/bulk`. File Excel
/// không gửi nguyên bản lên server — chỉ dữ liệu đã parse thành JSON.
class MaterialBulkImportScreen extends StatefulWidget {
  const MaterialBulkImportScreen({super.key});

  @override
  State<MaterialBulkImportScreen> createState() =>
      _MaterialBulkImportScreenState();
}

class _MaterialBulkImportScreenState extends State<MaterialBulkImportScreen> {
  final DmvtService _dmvtService = DmvtService();

  String? _fileName;
  List<_PreviewRow> _rows = [];
  bool _isParsing = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  String _cellText(
    List<xls.Data?> row,
    Map<String, int> headerIndex,
    String key,
  ) {
    final idx = headerIndex[key];
    if (idx == null || idx >= row.length) return '';
    return row[idx]?.value?.toString().trim() ?? '';
  }

  Future<void> _pickAndParseFile() async {
    setState(() => _errorMessage = null);

    FilePickerResult? result;
    try {
      result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );
    } catch (e) {
      setState(() => _errorMessage = 'Không thể mở trình chọn file: $e');
      return;
    }

    if (result == null || result.files.single.path == null) return;

    setState(() {
      _isParsing = true;
      _fileName = result!.files.single.name;
      _rows = [];
    });

    try {
      final bytes = await File(result.files.single.path!).readAsBytes();
      final excelFile = xls.Excel.decodeBytes(bytes);
      if (excelFile.tables.isEmpty) {
        setState(() {
          _isParsing = false;
          _errorMessage = 'File Excel không có sheet nào.';
        });
        return;
      }

      final sheet = excelFile.tables[excelFile.tables.keys.first]!;
      if (sheet.maxRows < 2) {
        setState(() {
          _isParsing = false;
          _errorMessage = 'File Excel trống hoặc thiếu dòng dữ liệu.';
        });
        return;
      }

      final rows = sheet.rows;
      final headerIndex = <String, int>{};
      for (int i = 0; i < rows.first.length; i++) {
        final value = rows.first[i]?.value?.toString().trim();
        if (value != null && value.isNotEmpty) headerIndex[value] = i;
      }

      final missingHeaders = [
        'maVt',
        'tenVt',
      ].where((h) => !headerIndex.containsKey(h)).toList();
      if (missingHeaders.isNotEmpty) {
        setState(() {
          _isParsing = false;
          _errorMessage =
              'Thiếu cột bắt buộc trong file: ${missingHeaders.join(', ')}.';
        });
        return;
      }

      final parsedRows = <_PreviewRow>[];
      final seenMaVt = <String>{};

      for (int r = 1; r < rows.length; r++) {
        final row = rows[r];
        final isEmptyRow = row.every(
          (c) => (c?.value?.toString().trim() ?? '').isEmpty,
        );
        if (isEmptyRow) continue;

        final maVt = _cellText(row, headerIndex, 'maVt');
        final tenVt = _cellText(row, headerIndex, 'tenVt');

        final material = Dmvt(
          aid: 0,
          maVt: maVt,
          tenVt: tenVt,
          dvt: _cellText(row, headerIndex, 'dvt'),
          danhDiemg: _cellText(row, headerIndex, 'danhDiemg'),
          danhDiemdd: _cellText(row, headerIndex, 'danhDiemdd'),
          danhDiemc: _cellText(row, headerIndex, 'danhDiemc'),
          thongSo: _cellText(row, headerIndex, 'thongSo'),
          hangSx: _cellText(row, headerIndex, 'hangSx'),
          ncSx: _cellText(row, headerIndex, 'ncSx'),
          ncc: _cellText(row, headerIndex, 'ncc'),
          hangXe: _cellText(row, headerIndex, 'hangXe'),
          dongXe: _cellText(row, headerIndex, 'dongXe'),
          hsCode: _cellText(row, headerIndex, 'hsCode'),
          ghiChu: _cellText(row, headerIndex, 'ghiChu'),
        );

        final errors = <String>[];
        if (maVt.isEmpty) errors.add('Thiếu mã vật tư');
        if (tenVt.isEmpty) errors.add('Thiếu tên vật tư');
        if (maVt.isNotEmpty && !seenMaVt.add(maVt))
          errors.add('Mã vật tư trùng trong file');

        parsedRows.add(
          _PreviewRow(rowNumber: r + 1, material: material, errors: errors),
        );
      }

      setState(() {
        _isParsing = false;
        _rows = parsedRows;
        if (parsedRows.isEmpty)
          _errorMessage = 'Không tìm thấy dòng dữ liệu nào trong file.';
      });
    } catch (e) {
      setState(() {
        _isParsing = false;
        _errorMessage = 'Lỗi đọc file Excel: $e';
      });
    }
  }

  Future<void> _handleSubmit() async {
    final validRows = _rows.where((r) => r.isValid).toList();
    if (validRows.isEmpty) return;

    setState(() => _isSubmitting = true);

    final result = await _dmvtService.bulkCreateMaterials(
      validRows.map((r) => r.material).toList(),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result["isSuccess"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã thêm thành công ${validRows.length} vật tư!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      final errors = result["errors"];
      String message =
          result["message"]?.toString() ??
          'Thêm hàng loạt thất bại (mã lỗi: ${result["statusCode"]})';
      if (errors is List && errors.isNotEmpty) {
        message =
            'Có ${errors.length} dòng bị server từ chối, không dòng nào được thêm. $message';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final validCount = _rows.where((r) => r.isValid).length;
    final invalidCount = _rows.length - validCount;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('Thêm hàng loạt vật tư'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chọn file Excel (.xlsx/.xls) có dòng tiêu đề với các cột: ${_kExpectedHeaders.join(', ')}.',
                  style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _isParsing ? null : _pickAndParseFile,
                  icon: const Icon(Icons.upload_file_rounded),
                  label: Text(
                    _fileName ?? 'Chọn file Excel',
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _kPrimaryColor,
                    side: const BorderSide(color: _kPrimaryColor),
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
                if (_rows.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Xem trước: $validCount dòng hợp lệ'
                    '${invalidCount > 0 ? ', $invalidCount dòng lỗi (sẽ bị bỏ qua)' : ''} / ${_rows.length} dòng.',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (_isParsing)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(color: _kPrimaryColor),
              ),
            ),
          if (!_isParsing && _rows.isNotEmpty)
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _rows.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final row = _rows[index];
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      row.isValid
                          ? Icons.check_circle_outline
                          : Icons.error_outline,
                      color: row.isValid ? Colors.green : Colors.redAccent,
                    ),
                    title: Text(
                      row.material.maVt.isNotEmpty
                          ? '${row.material.maVt} — ${row.material.tenVt}'
                          : '(Dòng ${row.rowNumber} thiếu mã vật tư)',
                      style: const TextStyle(fontSize: 13.5),
                    ),
                    subtitle: row.errors.isNotEmpty
                        ? Text(
                            row.errors.join(', '),
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 12,
                            ),
                          )
                        : null,
                  );
                },
              ),
            ),
        ],
      ),
      bottomNavigationBar: _rows.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: (_isSubmitting || validCount == 0)
                        ? null
                        : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kPrimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            validCount == 0
                                ? 'KHÔNG CÓ DÒNG HỢP LỆ'
                                : 'TẢI LÊN $validCount VẬT TƯ',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ),
    );
  }
}
