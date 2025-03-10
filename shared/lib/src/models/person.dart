class Person {
  final String id;
  final String name;
  final String personalNumber;

  Person({required this.id, required this.name, required this.personalNumber});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'personalNumber': personalNumber,
    };
  }

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'],
      name: json['name'],
      personalNumber: json['personalNumber'],
    );
  }
}