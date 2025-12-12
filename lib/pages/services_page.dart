import 'package:flutter/material.dart';
import 'package:petcare/models/service_model.dart';
import 'package:petcare/services/veterinary_service.dart';
import 'package:petcare/core/color_theme.dart';
import 'package:petcare/core/text_styles.dart';
import 'package:petcare/components/service_card.dart';
import 'package:petcare/components/custom_bottom_nav_bar.dart';
import 'package:petcare/pages/service_detail_page.dart';
import 'package:petcare/pages/start_page.dart';
import 'package:petcare/pages/configuration_page.dart';
import 'package:petcare/pages/products_page.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  final VeterinaryService _veterinaryService = VeterinaryService();

  List<ServiceModel> _allServices = [];
  List<ServiceModel> _filteredServices = [];

  bool _isLoading = true;
  String? _errorMessage;

  String? _selectedVeterinary;
  String _sortBy = 'default';

  Set<String> _veterinaries = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final servicesData = await _veterinaryService.getAllServices();
      final serviceModels = servicesData
          .map((s) => ServiceModel.fromJson(s))
          .toList();

      _buildFilterOptions(serviceModels);

      setState(() {
        _allServices = serviceModels;
        _filteredServices = serviceModels;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            'Error al cargar servicios. Por favor, intenta nuevamente.';
        _isLoading = false;
      });
      debugPrint('Error loading services: $e');
    }
  }

  void _buildFilterOptions(List<ServiceModel> services) {
    _veterinaries.clear();
    for (var service in services) {
      if (service.veterinary != null && service.veterinary!.isNotEmpty) {
        _veterinaries.add(service.veterinary!);
      }
    }
  }

  void _applyFilters() {
    List<ServiceModel> filtered = List.from(_allServices);

    if (_selectedVeterinary != null) {
      filtered = filtered
          .where((s) => s.veterinary == _selectedVeterinary)
          .toList();
    }

    switch (_sortBy) {
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
      _filteredServices = filtered;
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedVeterinary = null;
      _sortBy = 'default';
      _filteredServices = List.from(_allServices);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppColors.secondary),
              const SizedBox(height: 16),
              Text('Cargando servicios...', style: TextStyles.bodyTextBlack),
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
                const Icon(Icons.error_outline, color: Colors.red, size: 60),
                const SizedBox(height: 20),
                Text('Error', style: TextStyles.titleText),
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyles.bodyTextBlack,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loadData,
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
        title: Text('Servicios', style: TextStyles.titleText),
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
                      onChanged: (value) {
                        setState(() {
                          _filteredServices = _allServices.where((s) {
                            final nameLower = s.name.toLowerCase();
                            final queryLower = value.toLowerCase();
                            return nameLower.contains(queryLower);
                          }).toList();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Buscar servicio...',
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
              if (_selectedVeterinary != null || _sortBy != 'default')
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_selectedVeterinary != null)
                        Chip(
                          label: Text('Veterinaria: $_selectedVeterinary'),
                          onDeleted: () {
                            setState(() {
                              _selectedVeterinary = null;
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
                'Mostrando ${_filteredServices.length} servicios',
                style: TextStyles.bodyTextBlack.copyWith(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              if (_filteredServices.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No se encontraron servicios',
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
                    return GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio:
                                0.75, // Ajustado para tarjetas sin precio
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: _filteredServices.length,
                      itemBuilder: (context, index) {
                        final service = _filteredServices[index];
                        return ServiceCard(
                          service: service,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ServiceDetailPage(service: service),
                              ),
                            );
                          },
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
        currentIndex: 2, // Services tab index
        onTap: (index) {
          if (index == 2) return;
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const StartPage()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProductsPage()),
            );
          } else if (index == 4) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const ConfigurationPage(),
              ),
            );
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
                        Text('Filtros', style: TextStyles.titleText),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Veterinaria',
                      style: TextStyles.bodyTextBlack.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (var vet in _veterinaries)
                          ChoiceChip(
                            label: Text(vet),
                            selected: _selectedVeterinary == vet,
                            onSelected: (selected) {
                              setModalState(() {
                                _selectedVeterinary = selected ? vet : null;
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
