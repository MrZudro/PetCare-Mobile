import 'package:flutter/material.dart';
import 'package:petcare/core/color_theme.dart';
import 'package:petcare/components/textfield.dart';
import 'package:petcare/components/button.dart';
import 'package:petcare/services/address_service.dart';
import 'package:petcare/services/auth_service.dart';

class AddressFormPage extends StatefulWidget {
  final int customerId;
  final bool isAfterRegistration;

  const AddressFormPage({
    super.key,
    required this.customerId,
    this.isAfterRegistration = false,
  });

  @override
  State<AddressFormPage> createState() => _AddressFormPageState();
}

class _AddressFormPageState extends State<AddressFormPage> {
  final _formKey = GlobalKey<FormState>();
  final AddressService _addressService = AddressService();
  final AuthService _authService = AuthService();

  final TextEditingController _addressLineController = TextEditingController();
  final TextEditingController _additionalInfoController =
      TextEditingController();
  final TextEditingController _deliveryNotesController =
      TextEditingController();

  String _selectedAddressType = 'RESIDENTIAL'; // Default
  final List<String> _addressTypes = ['RESIDENTIAL', 'WORK', 'OTHER'];

  // Dropdown Data
  List<Map<String, dynamic>> localities = [];
  List<Map<String, dynamic>> allNeighborhoods = [];
  List<Map<String, dynamic>> filteredNeighborhoods = [];

  int? selectedLocalityId;
  int? selectedNeighborhoodId;
  bool isLoading = true;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    setState(() => isLoading = true);
    try {
      final locs = await _authService.fetchLocalities();
      final neighborhoods = await _authService.fetchNeighborhoods();

      if (mounted) {
        setState(() {
          localities = locs;
          allNeighborhoods = neighborhoods;

          localities.sort(
            (a, b) => (a['name'] as String).toLowerCase().compareTo(
              (b['name'] as String).toLowerCase(),
            ),
          );

          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error cargando datos: $e")));
      }
    }
  }

  void _filterNeighborhoods(int? localityId) {
    if (localityId == null) {
      setState(() {
        filteredNeighborhoods = [];
        selectedNeighborhoodId = null;
      });
      return;
    }
    setState(() {
      filteredNeighborhoods =
          allNeighborhoods.where((n) => n['localityId'] == localityId).toList()
            ..sort(
              (a, b) => (a['name'] as String).toLowerCase().compareTo(
                (b['name'] as String).toLowerCase(),
              ),
            );
      selectedNeighborhoodId = null;
    });
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (selectedNeighborhoodId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Por favor seleccione un barrio")),
        );
        return;
      }

      setState(() => isSubmitting = true);

      final addressData = {
        "addressLine": _addressLineController.text,
        "additionalInfo": _additionalInfoController.text,
        "deliveryNotes": _deliveryNotesController.text,
        "addressType": _selectedAddressType,
        "neighborhoodId": selectedNeighborhoodId,
        "isDefault": true, // First address as default?
      };

      final success = await _addressService.createAddress(
        widget.customerId,
        addressData,
      );

      if (mounted) {
        setState(() => isSubmitting = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Dirección guardada exitosamente")),
          );
          if (widget.isAfterRegistration) {
            // Navigate to login or home
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          } else {
            Navigator.pop(context, true);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error al guardar la dirección")),
          );
        }
      }
    }
  }

  void _skip() {
    if (widget.isAfterRegistration) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Agregar Dirección",
          style: TextStyle(
            color: AppColors.primary,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: widget.isAfterRegistration
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                onPressed: () => Navigator.pop(context),
              ),
        actions: widget.isAfterRegistration
            ? [
                TextButton(
                  onPressed: _skip,
                  child: const Text(
                    "Omitir",
                    style: TextStyle(color: Colors.grey, fontFamily: 'Poppins'),
                  ),
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildLabelledField(
                label: "Dirección",
                child: PersonalTextField(
                  controller: _addressLineController,
                  hintText: "Calle 123 # 45 - 67",
                  prefixIcon: Icons.location_on_outlined,
                ),
              ),
              const SizedBox(height: 15),

              _buildLabelledField(
                label: "Información Adicional",
                child: PersonalTextField(
                  controller: _additionalInfoController,
                  hintText: "Apto 201, Edificio...",
                  prefixIcon: Icons.info_outline,
                ),
              ),
              const SizedBox(height: 15),

              _buildLabelledField(
                label: "Tipo de Dirección",
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300, width: 1.5),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedAddressType,
                      isExpanded: true,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.grey.shade600,
                      ),
                      items: _addressTypes.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(
                            _translateType(type),
                            style: const TextStyle(fontFamily: 'Poppins'),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          setState(() => _selectedAddressType = val!),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Locality and Neighborhood (Copied logic from Registration)
              _buildLabelledField(
                label: "Localidad",
                child: _buildDropdown(
                  value: selectedLocalityId,
                  items: localities,
                  hint: "Seleccione...",
                  onChanged: (val) {
                    setState(() => selectedLocalityId = val);
                    _filterNeighborhoods(val);
                  },
                ),
              ),
              const SizedBox(height: 15),

              _buildLabelledField(
                label: "Barrio",
                child: _buildDropdown(
                  value: selectedNeighborhoodId,
                  items: filteredNeighborhoods,
                  hint: "Seleccione...",
                  onChanged: (val) =>
                      setState(() => selectedNeighborhoodId = val),
                ),
              ),
              const SizedBox(height: 15),

              _buildLabelledField(
                label: "Notas de Entrega (Opcional)",
                child: PersonalTextField(
                  controller: _deliveryNotesController,
                  hintText: "Dejar en portería...",
                  prefixIcon: Icons.note_alt_outlined,
                  maxLines: 3,
                ),
              ),
              const SizedBox(height: 30),

              isSubmitting
                  ? CircularProgressIndicator(color: AppColors.primary)
                  : PersonalButton(
                      text: "Guardar Dirección",
                      onPressed: _submit,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  String _translateType(String type) {
    switch (type) {
      case 'RESIDENTIAL':
        return 'Residencial';
      case 'WORK':
        return 'Trabajo';
      case 'OTHER':
        return 'Otro';
      default:
        return type;
    }
  }

  Widget _buildLabelledField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildDropdown({
    required int? value,
    required List<Map<String, dynamic>> items,
    required String hint,
    required ValueChanged<int?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          hint: Text(
            hint,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontFamily: 'Poppins',
              fontSize: 15,
            ),
          ),
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.grey.shade600,
            size: 24,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(16),
          items: items.map((Map<String, dynamic> item) {
            return DropdownMenuItem<int>(
              value: item['id'],
              child: Text(
                item['name'] ?? 'Unknown',
                style: const TextStyle(
                  color: Colors.black87,
                  fontFamily: 'Poppins',
                  fontSize: 15,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
