import 'package:flutter/material.dart';
import 'package:petcare/core/color_theme.dart';
import 'package:petcare/core/text_styles.dart';
import 'package:petcare/models/payment_method_model.dart';
import 'package:petcare/services/payment_method_service.dart';

class PaymentMethodFormPage extends StatefulWidget {
  const PaymentMethodFormPage({super.key});

  @override
  State<PaymentMethodFormPage> createState() => _PaymentMethodFormPageState();
}

class _PaymentMethodFormPageState extends State<PaymentMethodFormPage> {
  final _formKey = GlobalKey<FormState>();
  final PaymentMethodService _service = PaymentMethodService();

  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool isSubmitting = false;

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isSubmitting = true);

      // Simulate logic to determine Brand
      String brand = "Visa";
      if (_cardNumberController.text.startsWith('5')) brand = "Mastercard";

      // Extract Last 4
      String number = _cardNumberController.text.replaceAll(' ', '');
      int last4 = int.tryParse(number.substring(number.length - 4)) ?? 0;

      // Dummy Tokens
      final random = DateTime.now().millisecondsSinceEpoch.toString();
      final method = PaymentMethodModel(
        tokenPaymentMethod: "pm_$random",
        tokenClientGateway: "cg_$random",
        brand: brand,
        lastFourDigits: last4,
        expirationDate: _expiryController.text,
        isDefault: true, // First one usually default
      );

      final success = await _service.addPaymentMethod(method);

      if (mounted) {
        setState(() => isSubmitting = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tarjeta guardada exitosamente')),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al guardar tarjeta')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Agregar Tarjeta', style: TextStyles.titleText),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Nombre del Titular'),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration(
                  'Nombre como aparece en la tarjeta',
                ),
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 20),

              _buildLabel('Número de Tarjeta'),
              TextFormField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                maxLength: 16,
                decoration: _inputDecoration(
                  '0000 0000 0000 0000',
                  icon: Icons.credit_card,
                ),
                validator: (v) => v!.length < 16 ? 'Número inválido' : null,
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Expiración'),
                        TextFormField(
                          controller: _expiryController,
                          keyboardType: TextInputType.datetime,
                          decoration: _inputDecoration(
                            'MM/YY',
                            icon: Icons.calendar_today,
                          ),
                          validator: (v) => v!.isEmpty ? 'Requerido' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('CVV'),
                        TextFormField(
                          controller: _cvvController,
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          maxLength: 3,
                          decoration: _inputDecoration(
                            '123',
                            icon: Icons.lock_outline,
                          ),
                          validator: (v) => v!.length < 3 ? 'Inválido' : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Guardar Tarjeta',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyles.bodyTextBlack.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, {IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}
