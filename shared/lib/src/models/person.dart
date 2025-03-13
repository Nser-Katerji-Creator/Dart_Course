class Person {
  int? id;
  final String? name;
  final String? personalNumber;

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
      id: json['id'] as   int?,
      name: json['name'] as String?,
      personalNumber: json['personalNumber'] as String?,
    );
  }
}