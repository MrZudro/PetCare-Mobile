import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:petcare/components/button.dart';
import 'package:petcare/components/textfield.dart';
import 'package:petcare/core/color_theme.dart';
import 'package:petcare/core/text_styles.dart';
import 'package:petcare/models/user_model.dart';
import 'package:petcare/services/user_service.dart';
import 'package:petcare/services/cloudinary_service.dart';
import 'package:petcare/services/auth_service.dart';
import 'package:petcare/components/password_change_dialog.dart';

class EditProfilePage extends StatefulWidget {
  final UserModel user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _namesController;
  late TextEditingController _lastNamesController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _documentNumberController;
  late TextEditingController _dobController;

  String? _newPassword; // Store password from dialog

  final UserService _userService = UserService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  File? _imageFile;
  bool isSubmitting = false;

  // Dropdown data
  List<Map<String, dynamic>> docTypes = [];
  List<Map<String, dynamic>> localities = [];
  List<Map<String, dynamic>> allNeighborhoods = [];
  List<Map<String, dynamic>> filteredNeighborhoods = [];

  int? selectedDocTypeId;
  int? selectedLocalityId;
  int? selectedNeighborhoodId;
  bool isLoadingDropdowns = true;

  @override
  void initState() {
    super.initState();
    _namesController = TextEditingController(text: widget.user.names);
    _lastNamesController = TextEditingController(text: widget.user.lastNames);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phone);
    _addressController = TextEditingController(text: widget.user.address ?? '');
    _documentNumberController = TextEditingController(
      text: widget.user.documentNumber ?? '',
    );
    _dobController = TextEditingController(text: widget.user.birthDate ?? '');

    selectedDocTypeId = widget.user.documentTypeId;
    selectedNeighborhoodId = widget.user.neighborhoodId;

    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    setState(() => isLoadingDropdowns = true);
    try {
      final docs = await _authService.fetchDocumentTypes();
      final locs = await _authService.fetchLocalities();
      final neighborhoods = await _authService.fetchNeighborhoods();

      if (mounted) {
        setState(() {
          docTypes = docs;
          localities = locs;
          allNeighborhoods = neighborhoods;

          // Find locality for current neighborhood
          if (selectedNeighborhoodId != null) {
            final currentNeighborhood = allNeighborhoods.firstWhere(
              (n) => n['id'] == selectedNeighborhoodId,
              orElse: () => {},
            );
            if (currentNeighborhood.isNotEmpty) {
              selectedLocalityId = currentNeighborhood['localityId'];
              _filterNeighborhoods(selectedLocalityId);
            }
          }

          isLoadingDropdowns = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoadingDropdowns = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error cargando datos: $e')));
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
      filteredNeighborhoods = allNeighborhoods
          .where((n) => n['localityId'] == localityId)
          .toList();
      // Keep current neighborhood if it's in the filtered list
      if (selectedNeighborhoodId != null &&
          !filteredNeighborhoods.any(
            (n) => n['id'] == selectedNeighborhoodId,
          )) {
        selectedNeighborhoodId = null;
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.user.birthDate != null
          ? DateTime.tryParse(widget.user.birthDate!) ?? DateTime.now()
          : DateTime.now(),
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
      String formattedDate =
          "\${picked.year}-\${picked.month.toString().padLeft(2, '0')}-\${picked.day.toString().padLeft(2, '0')}";
      setState(() {
        _dobController.text = formattedDate;
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _namesController.dispose();
    _lastNamesController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _documentNumberController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _showPasswordChangeDialog() {
    showDialog(
      context: context,
      builder: (context) => PasswordChangeDialog(
        onConfirm: (currentPassword, newPassword) {
          // TODO: Validate current password with backend
          setState(() {
            _newPassword = newPassword;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Contraseña actualizada. Guarde los cambios.'),
            ),
          );
        },
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (widget.user.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: ID de usuario no disponible')),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      // Upload image if selected
      String? uploadedImageUrl;
      if (_imageFile != null) {
        uploadedImageUrl = await _cloudinaryService.uploadImage(_imageFile!);
        if (uploadedImageUrl == null) {
          if (mounted) {
            setState(() => isSubmitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error subiendo imagen')),
            );
          }
          return;
        }
      }

      // Prepare update data
      final updateData = {
        'names': _namesController.text,
        'lastNames': _lastNamesController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'documentNumber': _documentNumberController.text,
        'birthDate': _dobController.text,
        'documentTypeId': selectedDocTypeId,
        'neighborhoodId': selectedNeighborhoodId,
      };

      // Include password if changed via dialog
      if (_newPassword != null && _newPassword!.isNotEmpty) {
        updateData['password'] = _newPassword;
      }

      // Include uploaded image URL
      if (uploadedImageUrl != null) {
        updateData['profilePhotoUrl'] = uploadedImageUrl;
      }

      final success = await _userService.updateUser(
        widget.user.id!,
        updateData,
      );

      if (mounted) {
        setState(() => isSubmitting = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cambios guardados exitosamente')),
          );
          Navigator.pop(
            context,
            true,
          ); // Return true to indicate changes were made
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al guardar cambios')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => isSubmitting = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Ajustes de perfil', style: TextStyles.titleText),
        centerTitle: true,
      ),
      body: isLoadingDropdowns
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Profile Photo
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
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
                                  : (widget.user.profilePhotoUrl != null
                                        ? DecorationImage(
                                            image: NetworkImage(
                                              widget.user.profilePhotoUrl!,
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                        : null),
                              border: Border.all(color: Colors.white, width: 4),
                            ),
                            child:
                                _imageFile == null &&
                                    widget.user.profilePhotoUrl == null
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
                    ),
                    const SizedBox(height: 30),

                    // Names & Last Names
                    Row(
                      children: [
                        Expanded(
                          child: PersonalTextField(
                            controller: _namesController,
                            labelText: 'Nombres',
                            hintText: 'Ingrese sus nombres',
                            prefixIcon: Icons.person_outline,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: PersonalTextField(
                            controller: _lastNamesController,
                            labelText: 'Apellidos',
                            hintText: 'Ingrese sus apellidos',
                            prefixIcon: Icons.person_outline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Email
                    PersonalTextField(
                      controller: _emailController,
                      labelText: 'Correo electrónico',
                      hintText: 'Ingrese su correo',
                      prefixIcon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 20),

                    // Phone
                    PersonalTextField(
                      controller: _phoneController,
                      labelText: 'Teléfono',
                      hintText: 'Ingrese su teléfono',
                      prefixIcon: Icons.phone_outlined,
                    ),
                    const SizedBox(height: 20),

                    // Document Type & Number
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tipo de Documento',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildDropdown(
                                value: selectedDocTypeId,
                                items: docTypes,
                                hint: 'Seleccione...',
                                onChanged: (val) =>
                                    setState(() => selectedDocTypeId = val),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: PersonalTextField(
                            controller: _documentNumberController,
                            labelText: 'Número',
                            hintText: '...',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Birth Date
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: PersonalTextField(
                          controller: _dobController,
                          labelText: 'Fecha de Nacimiento',
                          hintText: 'AAAA-MM-DD',
                          prefixIcon: Icons.calendar_today,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Address
                    PersonalTextField(
                      controller: _addressController,
                      labelText: 'Dirección',
                      hintText: 'Ingrese su dirección',
                      prefixIcon: Icons.home_outlined,
                    ),
                    const SizedBox(height: 20),

                    // Locality
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Localidad',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildDropdown(
                          value: selectedLocalityId,
                          items: localities,
                          hint: 'Seleccione...',
                          onChanged: (val) {
                            setState(() => selectedLocalityId = val);
                            _filterNeighborhoods(val);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Neighborhood
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Barrio',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildDropdown(
                          value: selectedNeighborhoodId,
                          items: filteredNeighborhoods,
                          hint: 'Seleccione...',
                          onChanged: (val) =>
                              setState(() => selectedNeighborhoodId = val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Password Change Button
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundSecondary,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lock_outline,
                            color: AppColors.primary,
                            size: 28,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Contraseña',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                    color: AppColors.primaryText,
                                  ),
                                ),
                                Text(
                                  _newPassword != null
                                      ? 'Contraseña actualizada'
                                      : 'Toca para cambiar tu contraseña',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Poppins',
                                    color: _newPassword != null
                                        ? AppColors.success
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: _showPasswordChangeDialog,
                            icon: Icon(
                              _newPassword != null
                                  ? Icons.check_circle
                                  : Icons.arrow_forward_ios,
                              color: _newPassword != null
                                  ? AppColors.success
                                  : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    isSubmitting
                        ? CircularProgressIndicator(color: AppColors.primary)
                        : PersonalButton(
                            text: 'Guardar cambios',
                            onPressed: _saveChanges,
                          ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDropdown({
    required int? value,
    required List<Map<String, dynamic>> items,
    required String hint,
    required ValueChanged<int?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.primary),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          hint: Text(hint, style: const TextStyle(color: Colors.grey)),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
          items: items.map((Map<String, dynamic> item) {
            return DropdownMenuItem<int>(
              value: item['id'],
              child: Text(item['name'] ?? 'Unknown'),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
