class Person {
  //int? id;
  final String? name;
  final String? personalNumber;

  Person({required this.name, required this.personalNumber});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'personalNumber': personalNumber,
    };
  }

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      name: json['name'] as String?,
      personalNumber: json['personalNumber'] as String?,
    );
  }

  get statusCode => null;
}