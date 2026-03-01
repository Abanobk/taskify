class AddressModel {
  final String name;
  final String contact;
  final String address;
  final String city;
  final String state;
  final String country;
  final String zip;

  AddressModel({
    required this.name,
    required this.contact,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.zip,
  });

  // Factory constructor to create an instance from a JSON object
  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      name: json['name'] ?? '',
      contact: json['contact'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      zip: json['zip'] ?? '',
    );
  }

  // Method to convert the instance into a JSON object
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'contact': contact,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'zip': zip,
    };
  }
}
