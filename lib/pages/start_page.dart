import 'package:flutter/material.dart';
import 'package:petcare/core/color_theme.dart';
import 'package:petcare/components/custom_bottom_nav_bar.dart';
import 'package:petcare/pages/configuration_page.dart';
import 'package:petcare/pages/auth.dart';
import 'package:petcare/services/storage_service.dart';
import 'package:petcare/services/product_service.dart';
import 'package:petcare/services/veterinary_service.dart';
import 'package:petcare/services/wishlist_service.dart';
import 'package:petcare/pages/alerts_center_page.dart';
import 'package:petcare/pages/wishlist_page.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final StorageService _storageService = StorageService();
  final ProductService _productService = ProductService();
  final VeterinaryService _veterinaryService = VeterinaryService();
  final WishlistService _wishlistService = WishlistService();

  String userName = '';
  bool isLoading = true;

  List<Map<String, dynamic>> featuredProducts = [];
  List<Map<String, dynamic>> services = [];
  List<Map<String, dynamic>> topClinics = [];
  int wishlistCount = 0;
  int productCount = 0;
  int serviceCount = 0;
  int clinicCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    try {
      // Load user data
      final userData = await _storageService.getUserData();
      if (userData != null) {
        setState(() {
          userName = userData['names'] ?? 'Usuario';
        });
      }

      // Load all data in parallel with individual error handling
      final results = await Future.wait([
        _productService.getFeaturedProducts(limit: 10).catchError((e) {
          debugPrint('Error loading featured products: $e');
          return <Map<String, dynamic>>[];
        }),
        _veterinaryService.getActiveServices(limit: 6).catchError((e) {
          debugPrint('Error loading services: $e');
          return <Map<String, dynamic>>[];
        }),
        _veterinaryService.getTopRatedClinics(limit: 5).catchError((e) {
          debugPrint('Error loading clinics: $e');
          return <Map<String, dynamic>>[];
        }),
        _wishlistService.getWishlistCount().catchError((e) {
          debugPrint('Error loading wishlist count: $e');
          return 0;
        }),
        _productService.getAllProducts().catchError((e) {
          debugPrint('Error loading all products: $e');
          return <Map<String, dynamic>>[];
        }),
        _veterinaryService.getAllServices().catchError((e) {
          debugPrint('Error loading all services: $e');
          return <Map<String, dynamic>>[];
        }),
        _veterinaryService.getAllClinics().catchError((e) {
          debugPrint('Error loading all clinics: $e');
          return <Map<String, dynamic>>[];
        }),
      ]);

      if (mounted) {
        setState(() {
          featuredProducts = results[0] as List<Map<String, dynamic>>;
          services = results[1] as List<Map<String, dynamic>>;
          topClinics = results[2] as List<Map<String, dynamic>>;
          wishlistCount = results[3] as int;
          productCount = (results[4] as List).length;
          serviceCount = (results[5] as List).length;
          clinicCount = (results[6] as List).length;
          isLoading = false;
        });

        debugPrint('Data loaded successfully:');
        debugPrint('Featured Products: ${featuredProducts.length}');
        debugPrint('Services: ${services.length}');
        debugPrint('Top Clinics: ${topClinics.length}');
        debugPrint('Wishlist Count: $wishlistCount');
      }
    } catch (e) {
      debugPrint('Critical error loading data: $e');
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cargando datos: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.logout_rounded, color: AppColors.error),
              const SizedBox(width: 10),
              const Text(
                '¿Cerrar sesión?',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            'Si regresas, se cerrará tu sesión actual. ¿Estás seguro de que deseas continuar?',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: AppColors.tertiary,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _storageService.clearAuthData();
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const Auth()),
                    (Route<dynamic> route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Cerrar sesión',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (!didPop) {
          _showLogoutDialog(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_getGreeting()} 👋',
                style: const TextStyle(
                  color: Color.fromRGBO(51, 51, 51, 0.7),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  fontFamily: 'Poppins',
                ),
              ),
              Text(
                userName,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: AppColors.primary,
                size: 26,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AlertsCenterPage(),
                  ),
                );
              },
            ),
            // Wishlist Icon with Badge
            Stack(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.favorite_border,
                    color: AppColors.primary,
                    size: 26,
                  ),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WishlistPage(),
                      ),
                    );
                    // Reload data when returning from wishlist
                    _loadData();
                  },
                ),
                if (wishlistCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        wishlistCount > 9 ? '9+' : '$wishlistCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            IconButton(
              icon: const Icon(
                Icons.account_circle_outlined,
                color: AppColors.primary,
                size: 26,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ConfigurationPage(),
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : RefreshIndicator(
                onRefresh: _loadData,
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Quick Access Section
                        _buildSectionTitle('Acceso Rápido'),
                        const SizedBox(height: 16),
                        _buildQuickAccessGrid(),
                        const SizedBox(height: 32),

                        // Featured Products Section
                        _buildSectionTitle(
                          'Productos Destacados',
                          actionText: featuredProducts.isNotEmpty
                              ? 'Ver todos'
                              : null,
                          onAction: featuredProducts.isNotEmpty ? () {} : null,
                        ),
                        const SizedBox(height: 16),
                        featuredProducts.isNotEmpty
                            ? _buildProductsCarousel()
                            : _buildEmptyState('No hay productos disponibles'),
                        const SizedBox(height: 32),

                        // Services Section
                        _buildSectionTitle(
                          'Servicios Disponibles',
                          actionText: services.isNotEmpty ? 'Ver todos' : null,
                          onAction: services.isNotEmpty ? () {} : null,
                        ),
                        const SizedBox(height: 16),
                        services.isNotEmpty
                            ? _buildServicesGrid()
                            : _buildEmptyState('No hay servicios disponibles'),
                        const SizedBox(height: 32),

                        // Top Clinics Section
                        _buildSectionTitle(
                          'Clínicas Mejor Valoradas',
                          actionText: topClinics.isNotEmpty
                              ? 'Ver todas'
                              : null,
                          onAction: topClinics.isNotEmpty ? () {} : null,
                        ),
                        const SizedBox(height: 16),
                        topClinics.isNotEmpty
                            ? _buildClinicsSection()
                            : _buildEmptyState('No hay clínicas disponibles'),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: 0,
          onTap: (index) {
            if (index == 4) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ConfigurationPage(),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
    String title, {
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
            color: AppColors.primaryText,
          ),
        ),
        if (actionText != null && onAction != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              actionText,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuickAccessGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _buildQuickAccessCard(
          icon: Icons.shopping_bag_outlined,
          title: 'Productos',
          subtitle: '$productCount disponibles',
          color: AppColors.tertiary,
          onTap: () {},
        ),
        _buildQuickAccessCard(
          icon: Icons.medical_services_outlined,
          title: 'Servicios',
          subtitle: '$serviceCount disponibles',
          color: AppColors.primary,
          onTap: () {},
        ),
        _buildQuickAccessCard(
          icon: Icons.local_hospital_outlined,
          title: 'Clínicas',
          subtitle: '$clinicCount registradas',
          color: AppColors.success,
          onTap: () {},
        ),
        _buildQuickAccessCard(
          icon: Icons.favorite_outline,
          title: 'Mi Wishlist',
          subtitle: '$wishlistCount productos',
          color: AppColors.error,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildQuickAccessCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            const BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color.fromRGBO(color.red, color.green, color.blue, 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    color: Color.fromRGBO(51, 51, 51, 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsCarousel() {
    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: featuredProducts.length,
        itemBuilder: (context, index) {
          final product = featuredProducts[index];
          return _buildProductCard(product);
        },
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final price = (product['price'] as num?)?.toDouble() ?? 0.0;
    final stock = product['stock'] as int? ?? 0;

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          const BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              image: product['picture'] != null
                  ? DecorationImage(
                      image: NetworkImage(product['picture']),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: Stack(
              children: [
                if (stock <= 5)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Últimas $stock',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Product Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] ?? 'Producto',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product['brand'] ?? '',
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'Poppins',
                        color: const Color.fromRGBO(51, 51, 51, 0.6),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        final success = await _wishlistService.addToWishlist(
                          product['id'],
                        );
                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Agregado a favoritos'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          _loadData();
                        }
                      },
                      child: const Icon(
                        Icons.favorite_border,
                        size: 20,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: services.length > 6 ? 6 : services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return _buildServiceCard(service);
      },
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            const BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(0, 122, 255, 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: service['picture'] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        service['picture'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.medical_services,
                            color: AppColors.primary,
                            size: 28,
                          );
                        },
                      ),
                    )
                  : const Icon(
                      Icons.medical_services,
                      color: AppColors.primary,
                      size: 28,
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              service['name'] ?? 'Servicio',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: AppColors.primaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClinicsSection() {
    return Column(
      children: topClinics.map((clinic) => _buildClinicCard(clinic)).toList(),
    );
  }

  Widget _buildClinicCard(Map<String, dynamic> clinic) {
    final rating = (clinic['puntuacion'] as num?)?.toDouble() ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          const BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(76, 175, 80, 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_hospital,
              color: AppColors.success,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clinic['name'] ?? 'Clínica',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: const Color.fromRGBO(51, 51, 51, 0.8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  clinic['address'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    color: const Color.fromRGBO(51, 51, 51, 0.6),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Poppins',
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
