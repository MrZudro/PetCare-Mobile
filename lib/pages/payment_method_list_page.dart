import 'package:flutter/material.dart';
import 'package:petcare/core/color_theme.dart';
import 'package:petcare/core/text_styles.dart';
import 'package:petcare/models/payment_method_model.dart';
import 'package:petcare/services/payment_method_service.dart';
import 'payment_method_form_page.dart';

class PaymentMethodListPage extends StatefulWidget {
  const PaymentMethodListPage({super.key});

  @override
  State<PaymentMethodListPage> createState() => _PaymentMethodListPageState();
}

class _PaymentMethodListPageState extends State<PaymentMethodListPage> {
  final PaymentMethodService _service = PaymentMethodService();
  late Future<List<PaymentMethodModel>> _methodsFuture;

  @override
  void initState() {
    super.initState();
    _refreshMethods();
  }

  void _refreshMethods() {
    setState(() {
      _methodsFuture = _service.getUserPaymentMethods();
    });
  }

  Future<void> _deleteMethod(int id) async {
    final success = await _service.deletePaymentMethod(id);
    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Método de pago eliminado')),
        );
        _refreshMethods();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error eliminando método')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Mis Tarjetas', style: TextStyles.titleText),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<PaymentMethodModel>>(
        future: _methodsFuture,
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
                  const Icon(
                    Icons.credit_card_off,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes tarjetas guardadas',
                    style: TextStyles.bodyTextBlack,
                  ),
                ],
              ),
            );
          }

          final methods = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: methods.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final method = methods[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  gradient: method.isDefault
                      ? LinearGradient(
                          colors: [Colors.blue.shade900, Colors.blue.shade700],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
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
                    Icon(
                      Icons.credit_card,
                      color: method.isDefault
                          ? Colors.white
                          : AppColors.primary,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            method.brand.toUpperCase(),
                            style: TextStyles.bodyTextBlack.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: method.isDefault
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '**** **** **** ${method.lastFourDigits}',
                            style: TextStyles.bodyTextBlack.copyWith(
                              fontSize: 14,
                              color: method.isDefault
                                  ? Colors.white70
                                  : Colors.grey[600],
                            ),
                          ),
                          Text(
                            'Expira: ${method.expirationDate}',
                            style: TextStyles.bodyTextBlack.copyWith(
                              fontSize: 12,
                              color: method.isDefault
                                  ? Colors.white60
                                  : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: method.isDefault
                            ? Colors.white
                            : AppColors.error,
                      ),
                      onPressed: () => _deleteMethod(method.id ?? 0),
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
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PaymentMethodFormPage(),
            ),
          );
          if (result == true) {
            _refreshMethods();
          }
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_card, color: Colors.white),
        label: const Text(
          'Agregar Tarjeta',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
