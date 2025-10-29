import 'package:flutter/material.dart';

class AddAppendixScreen extends StatefulWidget {
  const AddAppendixScreen({super.key});

  @override
  State<AddAppendixScreen> createState() => _AddAppendixScreenState();
}

class _AddAppendixScreenState extends State<AddAppendixScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedUnit;
  String? selectedEmployee;
  String? selectedCategory;
  String? selectedCountry;
  String? selectedLocation;
  final TextEditingController nameController = TextEditingController();

  final List<String> units = ['Unit A', 'Unit B', 'Unit C'];
  final List<String> employees = ['John', 'Mary', 'David'];
  final List<String> categories = ['Category 1', 'Category 2'];
  final List<String> countries = ['VN', 'US', 'JP'];
  final List<String> locations = ['Hanoi', 'Saigon', 'Tokyo'];

  void _save() {
    if (_formKey.currentState!.validate()) {
      // Gửi dữ liệu lên API hoặc database
      final appendix = {
        "name": nameController.text,
        "unit": selectedUnit,
        "employee": selectedEmployee,
        "category": selectedCategory,
        "country": selectedCountry,
        "location": selectedLocation,
      };

      print("Phụ lục mới: $appendix");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu phụ lục mới!')),
      );
    }
  }

  Widget _buildDropdown(String label, List<String> items, String? value, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Vui lòng chọn $label' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm mới phụ lục')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên phụ lục',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập tên' : null,
              ),
              const SizedBox(height: 16),
              _buildDropdown('Unit', units, selectedUnit, (v) => setState(() => selectedUnit = v)),
              const SizedBox(height: 16),
              _buildDropdown('Employee', employees, selectedEmployee, (v) => setState(() => selectedEmployee = v)),
              const SizedBox(height: 16),
              _buildDropdown('Category', categories, selectedCategory, (v) => setState(() => selectedCategory = v)),
              const SizedBox(height: 16),
              _buildDropdown('Country', countries, selectedCountry, (v) => setState(() => selectedCountry = v)),
              const SizedBox(height: 16),
              _buildDropdown('Location', locations, selectedLocation, (v) => setState(() => selectedLocation = v)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Lưu phụ lục'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
