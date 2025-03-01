class ParkingSpace {
  String id;
  String adress;
  double prisPerTimme;

  ParkingSpace({
    required this.id,
    required this.adress,
    required this.prisPerTimme,
  });

  bool isValid() {
    return prisPerTimme > 0 && adress.isNotEmpty && id.isNotEmpty ;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'address': adress,
        'pricePerHour': prisPerTimme,
      };

  static ParkingSpace fromJson(Map<String, dynamic> json) => ParkingSpace(
        id: json['id'],
        adress: json['address'],
        prisPerTimme: json['pricePerHour'],
      );

  @override
  String toString() =>
      'ParkingSpace(id: $id, adress: $adress, prisPerTimme: $prisPerTimme)';
}
