class Person {
  
  String namn;
  String personnummer;

  Person({required this.namn, required this.personnummer});

  
  bool isValid() {
    // validation: personnummer should be exactly 10 digits
    final regex = RegExp(r'^\d{10}$');
    if(personnummer.isNotEmpty && namn.isNotEmpty && regex.hasMatch(personnummer)) {
      return  true;
    } else {
      return false;
    } 
  }

  Map<String, dynamic> toJson() => {
        'namn': namn,
        'personnummer': personnummer,
      };

  static Person fromJson(Map<String, dynamic> json) => Person(
        namn: json['name'],
        personnummer: json['personnummer'],
      );

  @override
  String toString() => 'Person(namn: $namn, personnummer: $personnummer)';
}