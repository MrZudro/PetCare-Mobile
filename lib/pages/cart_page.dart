import 'package:flutter/material.dart';
import '../core/color_theme.dart';
import '../core/text_styles.dart';
import '../models/cart_model.dart';
import '../services/cart_service.dart';


class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartService _cartService = CartService();
  late Future<List<CartItem>> _cartItemsFuture;

  @override
  void initState() {
    super.initState();
    _cartItemsFuture = _cartService.getCartItems();
  }

  @override
  Widget build(BuildContext context) {
    // Usamos LayoutBuilder para manejar el scroll si la lista es larga
    return Scaffold(
      backgroundColor: Colors.white, // Fondo general blanco
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.tertiary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<CartItem>>(
        future: _cartItemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error cargando el carrito', style: TextStyles.bodyTextBlack));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Tu carrito está vacío', style: TextStyles.bodyTextBlack));
          }

          final items = snapshot.data!;
          // Calcular totales dinámicamente
          final double subtotal = items.fold(0, (sum, item) => sum + item.price);
          final summary = OrderSummary(subtotal: subtotal, tax: 24.20, discount: 40.00);

          return Container(
            margin: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary, // Usando 0xFFF0F8FF (AliceBlue) según tu código
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Título
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mi carrito',
                          style: TextStyles.titleText.copyWith(color: AppColors.secondary),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Lista de tus productos',
                          style: TextStyles.bodyTextBlack.copyWith(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Lista de Productos (Scrollable)
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(24),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 30, color: Colors.black12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _buildCartItem(item);
                    },
                  ),
                ),

                // Sección de Resumen (Fija abajo)
                _buildOrderSummary(summary),
              ],
            ),
          );
        },
      ),
    );
  }

Widget _buildCartItem(CartItem item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Imagen del producto
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            image: DecorationImage(
              // Usamos NetworkImage para cargar las URLs de Cloudinary
              image: NetworkImage(item.imageUrl),
              fit: BoxFit.cover, // Cover se ve mejor para fotos de productos llenos
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
        ),
        const SizedBox(width: 15),
        // Detalles
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Usamos Flexible para evitar desbordamiento de texto si el nombre es largo
                  Flexible(
                    child: Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyles.titleText.copyWith(
                        fontSize: 16, // Ajustado ligeramente para nombres largos
                        color: AppColors.secondary
                      ),
                    ),
                  ),
                  Text(
                    '\$${item.price.toStringAsFixed(0)}', // Sin decimales para pesos colombianos si prefieres
                    style: TextStyles.titleText.copyWith(
                      fontSize: 18, 
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // AQUI CAMBIAMOS SIZE POR BRAND
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Marca: ${item.brand}',
                  style: TextStyles.bodyTextBlack.copyWith(
                    fontSize: 10, 
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyles.bodyTextBlack.copyWith(
                  fontSize: 12, 
                  color: Colors.grey[600]
                ),
              ),
            ],
          ),
        ),
        // Icono Eliminar
        IconButton(
          onPressed: () {}, 
          icon: const Icon(Icons.delete_outline, color: AppColors.error),
        )
      ],
    );
  }

  Widget _buildOrderSummary(OrderSummary summary) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.backgroundSecondary, // Mantiene el color de fondo suave
        border: Border(top: BorderSide(color: Colors.black12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen de la orden',
            style: TextStyles.titleText.copyWith(fontSize: 20, color: AppColors.secondary),
          ),
          Text(
            'Lista de todos tus items',
            style: TextStyles.bodyTextBlack.copyWith(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          _summaryRow('Precio base', summary.subtotal),
          _summaryRow('Impuestos', summary.tax),
          _summaryRow('Descuento', summary.discount),
          const Divider(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Total',
                    style: TextStyles.titleText.copyWith(
                      fontSize: 22, 
                      color: AppColors.tertiary // Purple
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Icon(Icons.info_outline, size: 16, color: AppColors.tertiary)
                ],
              ),
              Text(
                '\$${summary.total.toStringAsFixed(2)}',
                style: TextStyles.titleText.copyWith(
                  fontSize: 24, 
                  color: Colors.black, // El total es negro en la imagen
                  fontWeight: FontWeight.bold
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Botón Continuar
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary, // Cyan/Blue
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              onPressed: () {
                // Acción de facturación
              },
              child: Text(
                'Continuar a facturación',
                style: TextStyles.bodyTextBlack.copyWith(
                  color: Colors.white, // Asumimos texto blanco sobre fondo azul
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyles.bodyTextBlack.copyWith(
              color: AppColors.tertiary, // Purple según imagen
              fontSize: 15
            ),
          ),
          Text(
            '\$${value.toStringAsFixed(2)}',
            style: TextStyles.bodyTextBlack.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600
            ),
          ),
        ],
      ),
    );
  }
}