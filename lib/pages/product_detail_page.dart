import 'package:flutter/material.dart';
import 'package:petcare/models/product_model.dart';
import 'package:petcare/core/color_theme.dart';
import 'package:petcare/core/text_styles.dart';
import 'package:petcare/models/cart_model.dart';
import 'package:petcare/services/cart_service.dart';
import 'package:petcare/services/wishlist_service.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductModel product;
  final bool isWishlisted;
  final Function(int) onToggleWishlist;

  const ProductDetailPage({
    super.key,
    required this.product,
    required this.isWishlisted,
    required this.onToggleWishlist,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late bool _isWishlisted;
  int quantity = 1;
  final WishlistService _wishlistService = WishlistService();

  @override
  void initState() {
    super.initState();
    _isWishlisted = widget.isWishlisted;
    _checkWishlistStatus();
  }

  Future<void> _checkWishlistStatus() async {
    try {
      final products = await _wishlistService.getUserWishlist();
      // 'products' is now a List<Map> of the actual products

      final isFound = products.any((p) => p['id'] == widget.product.id);

      if (mounted) {
        setState(() {
          _isWishlisted = isFound;
        });
      }
    } catch (e) {
      debugPrint("Error checking wishlist: $e");
    }
  }

  Future<void> _toggleWishlist() async {
    // Optimistic UI update
    setState(() {
      _isWishlisted = !_isWishlisted;
    });

    bool success;
    if (_isWishlisted) {
      // Adding
      success = await _wishlistService.addToWishlist(widget.product.id);
    } else {
      // Removing
      success = await _wishlistService.removeFromWishlist(widget.product.id);
    }

    if (!success && mounted) {
      // Revert
      setState(() {
        _isWishlisted = !_isWishlisted;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error actualizando favoritos'),
          backgroundColor: AppColors.error,
        ),
      );
    } else {
      widget.onToggleWishlist(widget.product.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Container(
                height: 280,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: widget.product.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          widget.product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.pets,
                                size: 64,
                                color: Colors.grey.shade300,
                              ),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.pets,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                      ),
              ),
              const SizedBox(height: 24),

              // Product Title
              Text(
                widget.product.name,
                style: TextStyles.bodyTextBlack.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),

              // Brand
              if (widget.product.brand != null)
                Text(
                  widget.product.brand!,
                  style: TextStyles.bodyTextBlack.copyWith(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              const SizedBox(height: 16),

              // Price
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Precio',
                      style: TextStyles.bodyTextBlack.copyWith(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      '\$${widget.product.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match.group(1)}.')}',
                      style: TextStyles.bodyTextBlack.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Description
              Text(
                'Descripción',
                style: TextStyles.bodyTextBlack.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.product.description.isNotEmpty
                    ? widget.product.description
                    : 'Producto de alta calidad para el cuidado de tu mascota. Fabricado con materiales seguros y duraderos.',
                style: TextStyles.bodyTextBlack.copyWith(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),

              // Quantity Selector
              Text(
                'Cantidad',
                style: TextStyles.bodyTextBlack.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 20),
                      onPressed: quantity > 1
                          ? () => setState(() => quantity--)
                          : null,
                      color: AppColors.primary,
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          '$quantity',
                          style: TextStyles.bodyTextBlack.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 20),
                      onPressed: () => setState(() => quantity++),
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Add to Cart Button with Wishlist Heart
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Add products to cart
                        final cartService = CartService();
                        for (int i = 0; i < quantity; i++) {
                          cartService.addToCart(
                            CartItem(
                              id: widget.product.id.toString(),
                              name: widget.product.name,
                              description: widget.product.description,
                              brand: widget.product.brand ?? 'Sin marca',
                              price: widget.product.price,
                              imageUrl:
                                  widget.product.imageUrl ??
                                  'https://via.placeholder.com/150',
                            ),
                          );
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Se agregaron $quantity ${widget.product.name} al carrito',
                            ),
                            backgroundColor: AppColors.success,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.shopping_cart_outlined),
                      label: Text(
                        'Agregar al Carrito',
                        style: TextStyles.bodyTextBlack.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isWishlisted ? Icons.favorite : Icons.favorite_border,
                        color: AppColors.error,
                        size: 24,
                      ),
                      onPressed: _toggleWishlist,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
