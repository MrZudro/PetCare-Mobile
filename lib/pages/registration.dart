import 'package:flutter/material.dart';
import 'dart:io';
import 'package:petcare/core/color_theme.dart';
import 'package:petcare/components/textfield.dart';
import 'package:petcare/components/button.dart';
import 'package:petcare/services/auth_service.dart';
import 'package:petcare/models/register_request.dart';
import 'package:petcare/services/cloudinary_service.dart';
import 'package:petcare/services/image_service.dart';

class RegistrationPage extends StatefulWidget {
  final String email;
  final String password;

  const RegistrationPage({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ImageService _imageService = ImageService();
  File? _imageFile;

  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController docNumberController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  // Dropdown Data
  List<Map<String, dynamic>> docTypes = [];
  List<Map<String, dynamic>> localities = [];
  List<Map<String, dynamic>> allNeighborhoods = [];
  List<Map<String, dynamic>> filteredNeighborhoods = [];

  // Dropdown Selections (Stored as IDs)
  int? selectedDocTypeId;
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
      final docs = await _authService.fetchDocumentTypes();
      final locs = await _authService.fetchLocalities();
      final neighborhoods = await _authService.fetchNeighborhoods();

      if (mounted) {
        setState(() {
          docTypes = docs;
          localities = locs;
          allNeighborhoods = neighborhoods;

          // Sort alphabetically
          docTypes.sort(
            (a, b) => (a['name'] as String).toLowerCase().compareTo(
              (b['name'] as String).toLowerCase(),
            ),
          );
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.secondary,
              onPrimary: Colors.white,
              onSurface: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      // Format: YYYY-MM-DD for backend
      String formattedDate =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() {
        dobController.text = formattedDate;
      });
    }
  }

  Future<void> _pickImage() async {
    final File? croppedImage = await _imageService.pickAndCropImage(context);

    if (croppedImage != null) {
      setState(() {
        _imageFile = croppedImage;
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (selectedDocTypeId == null ||
          selectedLocalityId == null ||
          selectedNeighborhoodId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Por favor seleccione todas las opciones")),
        );
        return;
      }

      setState(() => isSubmitting = true);

      // Upload Image if selected
      String? uploadedImageUrl;
      if (_imageFile != null) {
        uploadedImageUrl = await _cloudinaryService.uploadImage(_imageFile!);
        if (uploadedImageUrl == null) {
          if (mounted) {
            setState(() => isSubmitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Error subiendo imagen")),
            );
          }
          return;
        }
      }

      final request = RegisterRequest(
        names: nameController.text,
        lastNames: surnameController.text,
        documentNumber: docNumberController.text,
        email: widget.email,
        password: widget.password,
        birthDate: dobController.text, // Ensure mapped correctly in _selectDate
        address: addressController.text,
        phone: phoneController.text,
        documentTypeId: selectedDocTypeId!,
        neighborhoodId: selectedNeighborhoodId,
        // Using uploaded URL or null
        profilePhotoUrl: uploadedImageUrl,
      );

      final success = await _authService.register(request);

      if (mounted) {
        setState(() => isSubmitting = false);
        if (success) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Registro exitoso")));
          // Navigate to Login or Home. For now popping back to Auth.
          // Ideally: Navigator.pushReplacementNamed(context, '/login');
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error en el registro. Verifique los datos."),
            ),
          );
        }
      }
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Completar Perfil",
          style: TextStyle(
            color: AppColors.primary,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Photo
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[200],
                              image: _imageFile != null
                                  ? DecorationImage(
                                      image: FileImage(_imageFile!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: _imageFile == null
                                ? Icon(
                                    Icons.camera_alt_outlined,
                                    size: 40,
                                    color: Colors.grey[500],
                                  )
                                : null,
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _imageFile != null
                            ? "Cambiar foto"
                            : "Sube tu foto de perfil",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Names & Surnames
              Row(
                children: [
                  Expanded(
                    child: _buildLabelledField(
                      label: "Nombres",
                      child: PersonalTextField(
                        controller: nameController,
                        hintText: "Tus nombres",
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildLabelledField(
                      label: "Apellidos",
                      child: PersonalTextField(
                        controller: surnameController,
                        hintText: "Tus apellidos",
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Doc Type
              _buildLabelledField(
                label: "Tipo de Documento",
                child: _buildDropdown(
                  value: selectedDocTypeId,
                  items: docTypes,
                  hint: "Seleccione...",
                  onChanged: (val) => setState(() => selectedDocTypeId = val),
                ),
              ),
              const SizedBox(height: 15),

              // Doc Number
              _buildLabelledField(
                label: "Número de Documento",
                child: PersonalTextField(
                  controller: docNumberController,
                  hintText: "Ingrese su número de documento",
                ),
              ),
              const SizedBox(height: 15),

              // Phone & DOB
              Row(
                children: [
                  Expanded(
                    child: _buildLabelledField(
                      label: "Teléfono",
                      child: PersonalTextField(
                        controller: phoneController,
                        hintText: "",
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildLabelledField(
                      label: "Fecha de Nacimiento",
                      child: GestureDetector(
                        onTap: () => _selectDate(context),
                        child: AbsorbPointer(
                          child: PersonalTextField(
                            controller: dobController,
                            hintText: "AAAA-MM-DD",
                            prefixIcon: Icons.calendar_today,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Address
              _buildLabelledField(
                label: "Dirección",
                child: PersonalTextField(
                  controller: addressController,
                  hintText: "",
                ),
              ),
              const SizedBox(height: 15),

              // Locality
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

              // Neighborhood
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
              const SizedBox(height: 40),

              isSubmitting
                  ? CircularProgressIndicator(color: AppColors.primary)
                  : PersonalButton(
                      text: "Finalizar Registro",
                      onPressed: _submit,
                    ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
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
