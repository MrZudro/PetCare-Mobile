import 'package:flutter/material.dart';

import 'dart:io';
import 'package:petcare/components/button.dart';
import 'package:petcare/components/textfield.dart';
import 'package:petcare/core/color_theme.dart';
import 'package:petcare/core/text_styles.dart';
import 'package:petcare/models/user_model.dart';
import 'package:petcare/services/user_service.dart';
import 'package:petcare/services/cloudinary_service.dart';
import 'package:petcare/services/auth_service.dart';
import 'package:petcare/services/image_service.dart';
import 'package:petcare/components/password_change_dialog.dart';
import 'package:petcare/pages/address_form_page.dart';

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
  late TextEditingController _documentNumberController;
  late TextEditingController _dobController;

  String? _newPassword; // Store password from dialog

  final UserService _userService = UserService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final AuthService _authService = AuthService();

  final ImageService _imageService = ImageService();

  File? _imageFile;
  bool isSubmitting = false;

  // Dropdown data
  List<Map<String, dynamic>> docTypes = [];

  int? selectedDocTypeId;
  bool isLoadingDropdowns = true;

  @override
  void initState() {
    super.initState();
    _namesController = TextEditingController(text: widget.user.names);
    _lastNamesController = TextEditingController(text: widget.user.lastNames);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phone);
    _documentNumberController = TextEditingController(
      text: widget.user.documentNumber ?? '',
    );
    _dobController = TextEditingController(text: widget.user.birthDate ?? '');

    selectedDocTypeId = widget.user.documentTypeId;

    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    setState(() => isLoadingDropdowns = true);
    try {
      final docs = await _authService.fetchDocumentTypes();

      if (mounted) {
        setState(() {
          docTypes = docs;

          // Sort localities and neighborhoods alphabetically
          docTypes.sort(
            (a, b) => (a['name'] as String).toLowerCase().compareTo(
              (b['name'] as String).toLowerCase(),
            ),
          );

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
    final File? croppedImage = await _imageService.pickAndCropImage(context);

    if (croppedImage != null) {
      setState(() {
        _imageFile = croppedImage;
      });
    }
  }

  @override
  void dispose() {
    _namesController.dispose();
    _lastNamesController.dispose();
    _emailController.dispose();
    _phoneController.dispose();

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
        'documentNumber': _documentNumberController.text,
        'birthDate': _dobController.text,
        'documentTypeId': selectedDocTypeId,
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

                    // Names
                    PersonalTextField(
                      controller: _namesController,
                      labelText: 'Nombres',
                      hintText: 'Ingrese sus nombres',
                      prefixIcon: Icons.person_outline,
                    ),
                    const SizedBox(height: 20),

                    // Last Names
                    PersonalTextField(
                      controller: _lastNamesController,
                      labelText: 'Apellidos',
                      hintText: 'Ingrese sus apellidos',
                      prefixIcon: Icons.person_outline,
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

                    // Document Type
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tipo de Documento',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
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
                    const SizedBox(height: 20),

                    // Document Number
                    PersonalTextField(
                      controller: _documentNumberController,
                      labelText: 'Número de Documento',
                      hintText: 'Ingrese su número de documento',
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

                    // Manage Addresses
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          if (widget.user.id != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddressFormPage(
                                  customerId: widget.user.id!,
                                  isAfterRegistration: false,
                                ),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.location_on_outlined),
                        label: const Text('Gestionar Direcciones'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          foregroundColor: AppColors.primary,
                        ),
                      ),
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
