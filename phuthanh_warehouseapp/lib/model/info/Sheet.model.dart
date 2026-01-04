  // Sheet.model.dart

  class Sheet {
    final int sheetAID;
    final String sheetID;
    final String nameSheet;
    final bool status;
    final String? remark;
    final String? lastUser;
    final DateTime? lastTime;

    Sheet({
      required this.sheetAID,
      required this.sheetID,
      required this.nameSheet,
      required this.status,
      this.remark,
      this.lastUser,
      this.lastTime,
    });

    // Chuyển từ JSON sang Object
    factory Sheet.fromJson(Map<String, dynamic> json) {
      return Sheet(
        sheetAID: json['SheetAID'] ?? 0,
        sheetID: json['SheetID'] ?? '',
        nameSheet: json['NameSheet'] ?? '',
        status: json['Status'] ?? '',
        lastUser: json['LastUser'],
        remark: json['Remark'],
        lastTime: DateTime.tryParse(json['LastTime'] ?? ''),
      );
    }

    // Chuyển từ Object sang JSON
    Map<String, dynamic> toJson() {
      return {
        // 'SheetAID': sheetAID,
        'SheetID': sheetID,
        'NameSheet': nameSheet,
        'Status': status,
        'LastUser': lastUser,
        'Remark': remark,
        'LastTime': DateTime.now().toIso8601String(),
      };
    }
      // Chuyển từ Object sang JSON
    Map<String, dynamic> toJsonUpdate() {
      return {
        'SheetAID': sheetAID,
        'SheetID': sheetID,
        'NameSheet': nameSheet,
        'Status': status,
        'LastUser': lastUser,
        'Remark': remark,
        'LastTime': DateTime.now().toIso8601String(),
      };
    }
  }
