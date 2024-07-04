class Customer {
  String id;
  String contactInfo;
  String location;
  String name;
  String position;

  Customer({
    required this.id,
    required this.contactInfo,
    required this.location,
    required this.name,
    required this.position,
  });

  factory Customer.fromMap(Map<String, dynamic> data, String documentId) {
    return Customer(
      id: documentId,
      contactInfo: data['contactInfo'],
      location: data['location'],
      name: data['name'],
      position: data['position'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'contactInfo': contactInfo,
      'location': location,
      'name': name,
      'position': position,
    };
  }
}
