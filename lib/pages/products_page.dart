import 'package:flutter/material.dart';
import 'package:petcare/models/product_model.dart';
import 'package:petcare/services/product_service.dart';
import 'package:petcare/services/wishlist_service.dart';
import 'package:petcare/core/color_theme.dart';
import 'package:petcare/core/text_styles.dart';
import 'package:petcare/components/product_card.dart';
import 'package:petcare/components/custom_bottom_nav_bar.dart';
import 'package:petcare/pages/start_page.dart';
import 'package:petcare/pages/configuration_page.dart';
import 'package:petcare/pages/product_detail_page.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final ProductService _productService = ProductService();
  final WishlistService _wishlistService = WishlistService();

  List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];

  bool _isLoading = true;
  String? _errorMessage;

  String? _selectedCategory;
  String? _selectedSubcategory;
  String? _selectedBrand;
  String _sortBy = 'default';

  Set<String> _categories = {};
  Set<String> _subcategories = {};
  Set<String> _brands = {};
  Map<String, Set<String>> _categoryToSubcategories = {};

  Map<int, int> _wishlistIds = {}; // productId -> wishlistId mapping
  // ...existing code...

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Load wishlist first, then products in parallel
    await _loadWishlist();
    await _loadProducts();
  }

  Future<void> _loadWishlist() async {
    // Load user's wishlist and build local mapping productId -> wishlistId
    try {
      final wishlist = await _wishlistService.getUserWishlist();
      if (mounted) {
        setState(() {
          _wishlistIds.clear();
          for (var item in wishlist) {
            final productId = item['productId'] as int?;
            final wishlistId = item['id'] as int?;
            if (productId != null && wishlistId != null) {
              _wishlistIds[productId] = wishlistId;
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading wishlist: $e');
    }
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final products = await _productService.getAllProducts();
      // Map API rows to DTOs. Show ALL products from the DB (no active filter)
      final productModels = products.map((p) => ProductModel.fromJson(p)).toList();

      _buildFilterOptions(productModels);

      setState(() {
        _allProducts = productModels;
        _filteredProducts = productModels;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            'Error al cargar los productos. Por favor, intenta nuevamente.';
        _isLoading = false;
      });
      debugPrint('Error loading products: $e');
    }
  }

  void _buildFilterOptions(List<ProductModel> products) {
    _categories.clear();
    _subcategories.clear();
    _brands.clear();
    _categoryToSubcategories.clear();

    for (var product in products) {
      if (product.category != null && product.category!.isNotEmpty) {
        _categories.add(product.category!);
      }
      if (product.subcategory != null && product.subcategory!.isNotEmpty) {
        _subcategories.add(product.subcategory!);
        // populate mapping category -> subcategories
        if (product.category != null && product.category!.isNotEmpty) {
          final cat = product.category!;
          final sub = product.subcategory!;
          _categoryToSubcategories.putIfAbsent(cat, () => <String>{});
          _categoryToSubcategories[cat]!.add(sub);
        }
      }
      if (product.brand != null && product.brand!.isNotEmpty) {
        _brands.add(product.brand!);
      }
    }
  }

  List<String> _availableSubcategoriesForSelected() {
    if (_selectedCategory != null) {
      final set = _categoryToSubcategories[_selectedCategory!];
      if (set != null && set.isNotEmpty) {
        final list = set.toList();
        list.sort();
        return list;
      }
      return <String>[];
    }
    final list = _subcategories.toList();
    list.sort();
    return list;
  }

  void _applyFilters() {
    List<ProductModel> filtered = List.from(_allProducts);

    if (_selectedCategory != null) {
      filtered = filtered.where((p) => p.category == _selectedCategory).toList();
    }

    if (_selectedSubcategory != null) {
      filtered = filtered
          .where((p) => p.subcategory == _selectedSubcategory)
          .toList();
    }

    if (_selectedBrand != null) {
      filtered = filtered.where((p) => p.brand == _selectedBrand).toList();
    }

    switch (_sortBy) {
      case 'price-asc':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price-desc':
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'name-asc':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'name-desc':
        filtered.sort((a, b) => b.name.compareTo(a.name));
        break;
      default:
        break;
    }

    setState(() {
      _filteredProducts = filtered;
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedSubcategory = null;
      _selectedBrand = null;
      _sortBy = 'default';
      _filteredProducts = List.from(_allProducts);
    });
  }

  void _toggleWishlist(int productId) async {
    if (_wishlistIds.containsKey(productId)) {
      // Remove from wishlist
      final wishlistId = _wishlistIds[productId]!;
      final success = await _wishlistService.removeFromWishlist(wishlistId);
      if (success && mounted) {
        setState(() {
          _wishlistIds.remove(productId);
        });
      }
    } else {
      // Add to wishlist
      final success = await _wishlistService.addToWishlist(productId);
      if (success) {
        // Reload wishlist to get the new wishlistId
        await _loadWishlist();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: AppColors.secondary,
              ),
              const SizedBox(height: 16),
              Text(
                'Cargando productos...',
                style: TextStyles.bodyTextBlack,
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                const SizedBox(height: 20),
                Text(
                  'Error',
                  style: TextStyles.titleText,
                ),
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyles.bodyTextBlack,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loadProducts,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Productos',
          style: TextStyles.titleText,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Buscar',
                style: TextStyles.titleText.copyWith(
                  fontSize: 20,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar producto...',
                        hintStyle: TextStyles.bodyTextBlack.copyWith(
                          color: Colors.grey,
                        ),
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _showFilterMenu,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.tune,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_selectedCategory != null ||
                  _selectedSubcategory != null ||
                  _selectedBrand != null ||
                  _sortBy != 'default')
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_selectedCategory != null)
                        Chip(
                          label: Text('Categoría: $_selectedCategory'),
                          onDeleted: () {
                            setState(() {
                              _selectedCategory = null;
                            });
                            _applyFilters();
                          },
                        ),
                      if (_selectedSubcategory != null)
                        Chip(
                          label: Text('Subcategoría: $_selectedSubcategory'),
                          onDeleted: () {
                            setState(() {
                              _selectedSubcategory = null;
                            });
                            _applyFilters();
                          },
                        ),
                      if (_selectedBrand != null)
                        Chip(
                          label: Text('Marca: $_selectedBrand'),
                          onDeleted: () {
                            setState(() {
                              _selectedBrand = null;
                            });
                            _applyFilters();
                          },
                        ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _clearFilters,
                        child: Text(
                          'Limpiar filtros',
                          style: TextStyles.bodyTextBlack.copyWith(
                            color: AppColors.secondary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Text(
                'Mostrando ${_filteredProducts.length} productos',
                style: TextStyles.bodyTextBlack.copyWith(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              if (_filteredProducts.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.shopping_bag_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No se encontraron productos',
                          style: TextStyles.bodyTextBlack.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = 2;
                    double childAspectRatio = 0.65;

                    return GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: childAspectRatio,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        final isWishlisted = _wishlistIds.containsKey(product.id);
                        return ProductCard(
                          product: product,
                          compact: true,
                          onQuickView: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailPage(
                                  product: product,
                                  isWishlisted: isWishlisted,
                                  onToggleWishlist: _toggleWishlist,
                                ),
                              ),
                            );
                          },
                          onToggleWishlist: _toggleWishlist,
                          isWishlisted: isWishlisted,
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StartPage()),
              );
            }
          } else if (index == 1) {
            // Already on Products
          } else if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ConfigurationPage()),
            );
          } else if (index == 2) {
            // Services - not implemented yet
          } else if (index == 3) {
            // Pets/Other - not implemented yet
          }
        },
      ),
    );
  }

  void _showFilterMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filtros',
                          style: TextStyles.titleText,
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Categoría',
                      style: TextStyles.bodyTextBlack.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (var category in _categories)
                          ChoiceChip(
                            label: Text(category),
                            selected: _selectedCategory == category,
                            onSelected: (selected) {
                              setModalState(() {
                                final wasSelected = _selectedCategory == category;
                                _selectedCategory = (selected && !wasSelected) ? category : null;
                                // clear subcategory when category changes
                                _selectedSubcategory = null;
                              });
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Subcategoría',
                      style: TextStyles.bodyTextBlack.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (var subcategory in _availableSubcategoriesForSelected())
                          ChoiceChip(
                            label: Text(subcategory),
                            selected: _selectedSubcategory == subcategory,
                            onSelected: (selected) {
                              setModalState(() {
                                _selectedSubcategory = selected ? subcategory : null;
                              });
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Marca',
                      style: TextStyles.bodyTextBlack.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (var brand in _brands)
                          ChoiceChip(
                            label: Text(brand),
                            selected: _selectedBrand == brand,
                            onSelected: (selected) {
                              setModalState(() {
                                _selectedBrand = selected ? brand : null;
                              });
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Ordenar por',
                      style: TextStyles.bodyTextBlack.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButton<String>(
                      value: _sortBy,
                      isExpanded: true,
                      items: [
                        DropdownMenuItem(
                          value: 'default',
                          child: Text('Ordenar por...'),
                        ),
                        DropdownMenuItem(
                          value: 'price-asc',
                          child: Text('Precio: Menor a Mayor'),
                        ),
                        DropdownMenuItem(
                          value: 'price-desc',
                          child: Text('Precio: Mayor a Menor'),
                        ),
                        DropdownMenuItem(
                          value: 'name-asc',
                          child: Text('Nombre: A-Z'),
                        ),
                        DropdownMenuItem(
                          value: 'name-desc',
                          child: Text('Nombre: Z-A'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setModalState(() {
                            _sortBy = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _clearFilters();
                            },
                            child: const Text('Limpiar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              setState(() {
                                _applyFilters();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                            ),
                            child: const Text('Aplicar'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
