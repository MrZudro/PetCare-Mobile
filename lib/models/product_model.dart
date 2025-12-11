class ProductModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final String? category;
  final String? subcategory;
  final String? brand;
  final bool isActive;
  final List<dynamic>? wishlists;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    this.category,
    this.subcategory,
    this.brand,
    this.isActive = true,
    this.wishlists,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Producto',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'],
      category: json['category'],
      subcategory: json['subcategory'],
      brand: json['brand'],
      isActive: json['isActive'] == 'ACTIVE' || json['isActive'] == true,
      wishlists: json['wishlists'] as List<dynamic>?,
    );
  }

  bool get isWishlisted => (wishlists?.length ?? 0) > 0;
}
