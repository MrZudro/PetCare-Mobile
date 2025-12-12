import 'package:flutter/material.dart';
import 'package:petcare/core/color_theme.dart';
import 'package:petcare/core/text_styles.dart';
import 'package:petcare/models/address_model.dart';
import 'package:petcare/services/address_service.dart';
import 'address_form_page.dart';

class AddressListPage extends StatefulWidget {
  const AddressListPage({super.key});

  @override
  State<AddressListPage> createState() => _AddressListPageState();
}

class _AddressListPageState extends State<AddressListPage> {
  final AddressService _addressService = AddressService();
  late Future<List<AddressModel>> _addressesFuture;

  @override
  void initState() {
    super.initState();
    _refreshAddresses();
  }

  void _refreshAddresses() {
    setState(() {
      _addressesFuture = _addressService.getUserAddresses();
    });
  }

  Future<void> _deleteAddress(int id) async {
    final success = await _addressService.deleteAddress(id);
    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Dirección eliminada')));
        _refreshAddresses();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error eliminando dirección')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Mis Direcciones', style: TextStyles.titleText),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<AddressModel>>(
        future: _addressesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes direcciones guardadas',
                    style: TextStyles.bodyTextBlack,
                  ),
                ],
              ),
            );
          }

          final addresses = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: addresses.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final address = addresses[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getIconForType(address.addressType),
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _translateType(address.addressType),
                            style: TextStyles.bodyTextBlack.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            address.addressLine,
                            style: TextStyles.bodyTextBlack.copyWith(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (address.additionalInfo != null)
                            Text(
                              address.additionalInfo!,
                              style: TextStyles.bodyTextBlack.copyWith(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                      ),
                      onPressed: () => _deleteAddress(address.id ?? 0),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Navigate to add address
          // Pass dummy customerId if needed by the constructor, or refactor constructor.
          // Since I plan to refactor AddressFormPage, I can decide here.
          // For now I'll pass 0 and rely on Service getting ID from token.
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddressFormPage(customerId: 0),
            ),
          );
          if (result == true) {
            _refreshAddresses();
          }
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Agregar Dirección',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'WORK':
        return Icons.work_outline;
      case 'OTHER':
        return Icons.location_on_outlined;
      default:
        return Icons.home_outlined;
    }
  }

  String _translateType(String type) {
    switch (type) {
      case 'RESIDENTIAL':
        return 'Casa';
      case 'WORK':
        return 'Trabajo';
      case 'OTHER':
        return 'Otro';
      default:
        return type;
    }
  }
}
