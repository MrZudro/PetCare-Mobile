import 'package:flutter/material.dart';
import 'package:petcare/core/color_theme.dart';
import 'package:petcare/core/text_styles.dart';

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _faqs = [
    {
      'category': 'Cuenta y Perfil',
      'icon': Icons.person_outline,
      'color': AppColors.primary,
      'questions': [
        {
          'question': '¿Cómo cambio mi contraseña?',
          'answer':
              'Ve a Ajustes de perfil, luego toca el botón de "Contraseña" y sigue las instrucciones para cambiarla de forma segura.',
        },
        {
          'question': '¿Puedo actualizar mi información personal?',
          'answer':
              'Sí, ve a Ajustes de perfil donde podrás editar tu nombre, teléfono, dirección y otros datos personales.',
        },
        {
          'question': '¿Cómo desactivo mi cuenta?',
          'answer':
              'En la página de configuración, encontrarás la opción "Desactivar cuenta". Ten en cuenta que esta acción es reversible contactando a soporte.',
        },
      ],
    },
    {
      'category': 'Mascotas',
      'icon': Icons.pets,
      'color': AppColors.secondary,
      'questions': [
        {
          'question': '¿Cómo registro una nueva mascota?',
          'answer':
              'Ve a la sección de Mascotas y toca el botón "Agregar Mascota". Completa el formulario con los datos de tu mascota.',
        },
        {
          'question': '¿Puedo tener múltiples mascotas registradas?',
          'answer':
              'Sí, puedes registrar todas las mascotas que desees en tu cuenta sin límite.',
        },
        {
          'question': '¿Cómo actualizo la información de mi mascota?',
          'answer':
              'En la sección de Mascotas, selecciona la mascota que deseas editar y actualiza su información.',
        },
      ],
    },
    {
      'category': 'Citas y Servicios',
      'icon': Icons.calendar_today,
      'color': AppColors.tertiary,
      'questions': [
        {
          'question': '¿Cómo agendo una cita veterinaria?',
          'answer':
              'Ve a la sección de Servicios Médicos, selecciona el servicio deseado y elige la fecha y hora disponible.',
        },
        {
          'question': '¿Puedo cancelar o reprogramar una cita?',
          'answer':
              'Sí, ve a "Mis Solicitudes" donde podrás ver tus citas y modificarlas con al menos 24 horas de anticipación.',
        },
        {
          'question': '¿Qué servicios veterinarios ofrecen?',
          'answer':
              'Ofrecemos consultas generales, vacunación, cirugías, análisis de laboratorio, peluquería y más.',
        },
      ],
    },
    {
      'category': 'Compras y Pagos',
      'icon': Icons.shopping_bag_outlined,
      'color': AppColors.primary,
      'questions': [
        {
          'question': '¿Qué métodos de pago aceptan?',
          'answer':
              'Aceptamos tarjetas de crédito, débito, transferencias bancarias y pagos en efectivo en nuestras instalaciones.',
        },
        {
          'question': '¿Cómo veo mi historial de compras?',
          'answer':
              'En la página de configuración, toca "Historial de Compras" para ver todas tus transacciones.',
        },
        {
          'question': '¿Puedo devolver un producto?',
          'answer':
              'Sí, aceptamos devoluciones dentro de los 30 días posteriores a la compra con el producto en su empaque original.',
        },
      ],
    },
    {
      'category': 'Seguridad',
      'icon': Icons.security,
      'color': AppColors.secondary,
      'questions': [
        {
          'question': '¿Mis datos están seguros?',
          'answer':
              'Sí, utilizamos encriptación de última generación y cumplimos con todas las normativas de protección de datos.',
        },
        {
          'question': '¿Qué hago si olvido mi contraseña?',
          'answer':
              'En la pantalla de inicio de sesión, toca "¿Olvidaste tu contraseña?" y sigue las instrucciones para restablecerla.',
        },
        {
          'question': '¿Puedo cerrar sesión en todos los dispositivos?',
          'answer':
              'Sí, al cambiar tu contraseña, se cerrarán automáticamente todas las sesiones activas en otros dispositivos.',
        },
      ],
    },
  ];

  List<Map<String, dynamic>> get _filteredFaqs {
    if (_searchQuery.isEmpty) {
      return _faqs;
    }

    return _faqs
        .map((category) {
          final filteredQuestions = (category['questions'] as List)
              .where(
                (q) =>
                    q['question'].toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    q['answer'].toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ),
              )
              .toList();

          return {...category, 'questions': filteredQuestions};
        })
        .where((category) => (category['questions'] as List).isNotEmpty)
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        title: const Text('Centro de Ayuda', style: TextStyles.titleText),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar preguntas...',
                hintStyle: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.grey.shade500,
                ),
                prefixIcon: Icon(Icons.search, color: AppColors.primary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey.shade500),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),

          // FAQ List
          Expanded(
            child: _filteredFaqs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No se encontraron resultados',
                          style: TextStyles.bodyTextBlack.copyWith(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _filteredFaqs.length,
                    itemBuilder: (context, index) {
                      final category = _filteredFaqs[index];
                      return _buildCategorySection(category, index);
                    },
                  ),
          ),

          // Contact Support Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement contact support
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Contactando con soporte...'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.support_agent),
                label: const Text('Contactar Soporte'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
    Map<String, dynamic> category,
    int categoryIndex,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (categoryIndex * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Header
          Padding(
            padding: const EdgeInsets.only(bottom: 12, top: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (category['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    category['icon'] as IconData,
                    color: category['color'] as Color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  category['category'],
                  style: TextStyles.titleText.copyWith(
                    fontSize: 18,
                    color: AppColors.primaryText,
                  ),
                ),
              ],
            ),
          ),

          // Questions
          ...List.generate((category['questions'] as List).length, (index) {
            final question = (category['questions'] as List)[index];
            return _buildQuestionTile(question);
          }),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildQuestionTile(Map<String, dynamic> question) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: AppColors.primary.withOpacity(0.05),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text(
            question['question'],
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
          iconColor: AppColors.primary,
          collapsedIconColor: AppColors.tertiary,
          children: [
            Text(
              question['answer'],
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
