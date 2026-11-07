import 'package:phuthanh_warehouseapp/model/newwarehouse/DanhMuc.model.dart';
import 'package:phuthanh_warehouseapp/model/shared/Employee.model.dart';

/// Ghi nhớ NCC/khách hàng và nhân viên vừa chọn khi quét mã thêm nhập/xuất
/// hoặc điều chuyển, để lần quét sau không phải chọn lại. Chỉ lưu trong bộ
/// nhớ (static field) — tồn tại đúng vòng đời của tiến trình app, tắt app
/// (kill process) là mất, không ghi xuống SharedPreferences/đĩa.
class PinnedLookupStore {
  PinnedLookupStore._();

  static Customer? pinnedCustomer;
  static Employee? pinnedEmployee;
  static String? pinnedLocation;

  static bool isCustomerPinned(Customer? value) {
    return value != null && pinnedCustomer?.maKh == value.maKh;
  }

  static bool isEmployeePinned(Employee? value) {
    return value != null && pinnedEmployee?.EmployeeID == value.EmployeeID;
  }

  static bool isLocationPinned(String? value) {
    final normalized = value?.trim() ?? '';
    return normalized.isNotEmpty && pinnedLocation == normalized;
  }

  static void toggleCustomerPin(Customer? current) {
    pinnedCustomer = isCustomerPinned(current) ? null : current;
  }

  static void toggleEmployeePin(Employee? current) {
    pinnedEmployee = isEmployeePinned(current) ? null : current;
  }

  static void toggleLocationPin(String? current) {
    final normalized = current?.trim() ?? '';
    pinnedLocation = isLocationPinned(normalized)
        ? null
        : (normalized.isEmpty ? null : normalized);
  }
}
