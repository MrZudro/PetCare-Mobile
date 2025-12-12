import '../models/cart_model.dart';
// import 'package:http/http.dart' as http;
// import '../core/api_constants.dart';

class CartService {
  static final CartService _instance = CartService._internal();

  factory CartService() {
    return _instance;
  }

  CartService._internal();

  final List<CartItem> _items = [];

  Future<List<CartItem>> getCartItems() async {
    // Simulate network delay if desired, or just return immediately
    // await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_items);
  }

  void addToCart(CartItem item) {
    _items.add(item);
  }
}
