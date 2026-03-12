class OptionAction {
  final int id;
  final String name;

  OptionAction({
    required this.id,
    required this.name,
  });

  factory OptionAction.fromJson(Map<String, dynamic> json) {
    return OptionAction(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
