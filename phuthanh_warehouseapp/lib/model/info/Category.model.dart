class Category {
  final int CategoryID;
  final String Name;

  Category({required this.CategoryID, required this.Name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      CategoryID: (json['CategoryID'] as num?)?.toInt() ?? 0,
      Name: json['Name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'CategoryID': CategoryID, 'Name': Name};
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category && other.CategoryID == CategoryID);

  @override
  int get hashCode => CategoryID.hashCode;
}
