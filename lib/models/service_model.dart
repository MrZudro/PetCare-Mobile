class ServiceModel {
  final int id;
  final String name;
  final String description;
  final String? imageUrl;
  final String? status;
  final String? veterinary;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    this.status,
    this.veterinary,  
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    // Handle veterinary field which might be an object or a string
    String? vetName;
    if (json['veterinary'] is String) {
      vetName = json['veterinary'];
    } else if (json['veterinary'] is Map) {
      vetName = json['veterinary']['name'];
    }

    return ServiceModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Servicio',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'],
      status: json['status'],
      veterinary: vetName,
    );
  }
}
