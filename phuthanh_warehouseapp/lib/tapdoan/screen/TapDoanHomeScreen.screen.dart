import 'package:flutter/material.dart';
import 'package:phuthanh_warehouseapp/helper/ChangeSystemDialog.helper.dart';
import 'package:phuthanh_warehouseapp/model/tapdoan/Company.model.dart';
import 'package:phuthanh_warehouseapp/tapdoan/screen/CompanyInventoryScreen.screen.dart';

const Color _kPrimaryColor = Color(0xFF0E6B6B);

/// Điểm vào hệ thống kho tập đoàn: chọn 1 trong 5 công ty thành viên.
class TapDoanHomeScreen extends StatelessWidget {
  const TapDoanHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('Kho tập đoàn'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Đổi hệ thống',
            icon: const Icon(kChangeSystemIcon, color: kChangeSystemColor),
            onPressed: () => showChangeSystemDialog(context),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: kCompanies.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final company = kCompanies[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE3F1F1),
                child: Icon(Icons.warehouse_outlined, color: _kPrimaryColor),
              ),
              title: Text(company.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Mã: ${company.code.toUpperCase()}'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CompanyInventoryScreen(company: company)),
              ),
            ),
          );
        },
      ),
    );
  }
}
