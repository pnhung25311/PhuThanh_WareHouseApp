class StatusSystem {
  final int statusID; // 🆕 ID của status
  final String nameStatus;
  final dynamic typeStatus; // 1 hoặc 2
  final String remark;

  StatusSystem({
    required this.statusID,
    required this.nameStatus,
    required this.typeStatus,
    required this.remark,
  });

  /// ✅ Tạo từ JSON
  factory StatusSystem.fromJson(Map<String, dynamic> json) {
    return StatusSystem(
      statusID: json['StatusID'] is int
          ? json['StatusID']
          : int.tryParse(json['StatusID']?.toString() ?? '0') ?? 0,
      nameStatus: json['NameStatus'] ?? '',
      typeStatus: json['TypeStatus'] ?? '',
      remark: json['Remark'] ?? '',
    );
  }

  /// ✅ Chuyển về JSON
  Map<String, dynamic> toJson() {
    return {
      'StatusID': statusID,
      'NameStatus': nameStatus,
      'TypeStatus': typeStatus,
      'Remark': remark,
    };
  }

  /// ✅ Lấy giá trị kiểu bool từ TypeStatus
  bool get isTrue => typeStatus == '1';
  bool get isFalse => typeStatus == '0';

  bool getBool(String condition) => condition == "1" ? true : false;

  /// ✅ Copy model (giữ nguyên hoặc thay đổi 1 số giá trị)
  StatusSystem copyWith({
    int? statusID,
    String? nameStatus,
    String? typeStatus,
    String? remark,
  }) {
    return StatusSystem(
      statusID: statusID ?? this.statusID,
      nameStatus: nameStatus ?? this.nameStatus,
      typeStatus: typeStatus ?? this.typeStatus,
      remark: remark ?? this.remark,
    );
  }

  /// ✅ So sánh hai model
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StatusSystem &&
        other.statusID == statusID &&
        other.nameStatus == nameStatus &&
        other.typeStatus == typeStatus &&
        other.remark == remark;
  }

  @override
  int get hashCode => Object.hash(statusID, nameStatus, typeStatus, remark);

  /// ✅ Hiển thị thông tin gọn gàng khi debug
  @override
  String toString() {
    return 'StatusSystem(StatusID: $statusID, NameStatus: $nameStatus, TypeStatus: $typeStatus, Remark: $remark)';
  }

  /// ✅ Parse từ list JSON
  static List<StatusSystem> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((e) => StatusSystem.fromJson(e)).toList();
  }

  /// ✅ Convert list model → JSON
  static List<Map<String, dynamic>> toJsonList(List<StatusSystem> list) {
    return list.map((e) => e.toJson()).toList();
  }

  /// ✅ Tạo model mặc định
  factory StatusSystem.empty() =>
      StatusSystem(statusID: 0, nameStatus: '', typeStatus: '', remark: '');
}
