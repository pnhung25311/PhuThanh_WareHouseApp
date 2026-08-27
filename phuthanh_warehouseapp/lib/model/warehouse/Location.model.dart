class Location {
  final int LocationID;
  final String NameLocation;

  Location({
    required this.LocationID,
    required this.NameLocation,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      LocationID: json['LocationID'],
      NameLocation: json['NameLocation'],
    );
  }

  Map<String, dynamic> toJson() => {
        'LocationID': LocationID,
        'NameLocation': NameLocation,
      };

  @override
  String toString() => 'Location(ID: $LocationID, Name: $NameLocation)';

  @override
bool operator ==(Object other) =>
    identical(this, other) ||
    (other is Location && other.LocationID == LocationID);

@override
int get hashCode => LocationID.hashCode;

}
