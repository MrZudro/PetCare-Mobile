class CartItem {
  final String id;
  final String name;
  final String description;
  final String brand;
  final double price;
  final String imageUrl;

  CartItem({
    required this.id,
    required this.name,
    required this.description,
    required this.brand,
    required this.price,
    required this.imageUrl,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      brand: json['brand'],
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'],
    );
  }
}

class OrderSummary {
  final double subtotal;
  final double tax;
  final double discount;
  
  OrderSummary({
    required this.subtotal,
    required this.tax,
    required this.discount
  });

  double get total => subtotal + tax - discount;
}