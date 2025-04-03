class Person {
  final String id;
  final String? name;
  final String? personalNumber;

  Person({required this.name, required this.personalNumber, required this.id});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'personalNumber': personalNumber,
    };
  }

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'] as String,
      name: json['name'] as String?,
      personalNumber: json['personalNumber'] as String?,
    );
  }
}
