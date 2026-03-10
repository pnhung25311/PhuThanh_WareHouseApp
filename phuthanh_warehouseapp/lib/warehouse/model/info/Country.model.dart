class Country {
  final int CountryID;
  final String Name;

  Country({
    required this.CountryID,
    required this.Name,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      CountryID: (json['CountryID'] as num?)?.toInt() ?? 0,
      Name: json['Name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CountryID': CountryID,
      'Name': Name,
    };
  }
@override
bool operator ==(Object other) =>
    identical(this, other) ||
    (other is Country && other.CountryID == CountryID);

@override
int get hashCode => CountryID.hashCode;

  
}

