import 'package:flutter/material.dart';
import 'package:petcare/core/color_theme.dart';
import 'package:petcare/components/textfield.dart';
import 'package:petcare/components/button.dart';

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

  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController docNumberController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  // Dropdown Values
  String? selectedDocType;
  String? selectedLocality;
  String? selectedNeighborhood;

  // Mock Data for UI demonstration (empty as requested for dynamic loading)
  final List<String> docTypes = ["C.C.", "T.I.", "C.E.", "Pasaporte"];
  final List<String> localities = []; // To be filled from API
  final List<String> neighborhoods = []; // To be filled based on locality

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
      setState(() {
        dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
              // Profile Photo Placeholder
              Center(
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
                            border: Border.all(
                              color: Colors.white,
                              width: 4,
                            ), // Optional white border
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.camera_alt_outlined,
                            size: 40,
                            color: Colors.grey[500],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.secondary, // Purple/Blue accent
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Sube tu foto de perfil",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
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
                        // Assuming PersonalTextField handles decoration internally but we need consistent external spacing/labels as per design image which has labels ABOVE fields
                        // The PersonalTextField implementation viewed before has labelText in InputDecoration.
                        // But Design shows label OUTSIDE/ABOVE or distinct.
                        // Check PersonalTextField implementation again?
                        // It has `labelText` in generic creation.
                        // Looking at image 2: Labels are outside "Nombres", "Apellidos".
                        // I will wrap in a helper or use PersonalTextField's label and adjust usage?.
                        // Image 2 clearly shows labels above the input box (which is outlined).
                        // PersonalTextField uses InputDecoration label, which usually animates or stays inside.
                        // To match Image 2 exactly, I should put text above.
                        // I'll stick to using PersonalTextField for simplicity but maybe hide its label if I render outside, OR just use its label.
                        // I will render label OUTSIDE and pass empty label to PersonalTextField for "hint" behavior primarily.
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

              // Doc Type & Number
              Row(
                children: [
                  Expanded(
                    child: _buildLabelledField(
                      label: "Tipo de Documento",
                      child: _buildDropdown(
                        value: selectedDocType,
                        items: docTypes,
                        hint: "Seleccione...",
                        onChanged: (val) =>
                            setState(() => selectedDocType = val),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildLabelledField(
                      label: "Número de Documento",
                      child: PersonalTextField(
                        controller: docNumberController,
                        hintText: "...",
                      ),
                    ),
                  ),
                ],
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
                            hintText: "dd/mm/aaaa",
                            prefixIcon:
                                Icons.calendar_today, // Optional, looks good
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

              // Locality (Requested Extra Field)
              _buildLabelledField(
                label: "Localidad",
                child: _buildDropdown(
                  value: selectedLocality,
                  items: localities,
                  hint: "Seleccione...",
                  onChanged: (val) => setState(() => selectedLocality = val),
                ),
              ),
              const SizedBox(height: 15),

              // Neighborhood
              _buildLabelledField(
                label: "Barrio (Opcional)",
                child: _buildDropdown(
                  value: selectedNeighborhood,
                  items: neighborhoods,
                  hint: "Seleccione...",
                  onChanged: (val) =>
                      setState(() => selectedNeighborhood = val),
                ),
              ),
              const SizedBox(height: 40),

              PersonalButton(
                text: "Finalizar Registro",
                onPressed: () {
                  print("Registration Data:");
                  print("Email: ${widget.email}");
                  print("Name: ${nameController.text}");
                  // Logic to submit to API
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Helper to match design where Label is above the input
  Widget _buildLabelledField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  // Custom Dropdown to match PersonalTextField style
  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white, // Or transparent if background is colored
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.primary),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: TextStyle(color: Colors.grey)),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
          items: items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
