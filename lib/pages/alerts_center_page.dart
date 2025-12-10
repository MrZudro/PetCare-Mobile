import 'package:flutter/material.dart';
import 'package:petcare/core/color_theme.dart';
import 'package:petcare/core/text_styles.dart';

class AlertsCenterPage extends StatefulWidget {
  const AlertsCenterPage({super.key});

  @override
  State<AlertsCenterPage> createState() => _AlertsCenterPageState();
}

class _AlertsCenterPageState extends State<AlertsCenterPage>
    with SingleTickerProviderStateMixin {
  String _selectedCategory = 'Todas';
  late AnimationController _animationController;

  final List<Map<String, dynamic>> _alerts = [
    {
      'id': 1,
      'title': 'Cita Próxima',
      'message': 'Tienes una cita veterinaria mañana a las 10:00 AM',
      'category': 'Citas',
      'time': '2 horas',
      'isRead': false,
      'icon': Icons.calendar_today,
      'color': AppColors.primary,
    },
    {
      'id': 2,
      'title': '¡Oferta Especial!',
      'message': '20% de descuento en todos los productos para mascotas',
      'category': 'Promociones',
      'time': '5 horas',
      'isRead': false,
      'icon': Icons.local_offer,
      'color': AppColors.secondary,
    },
    {
      'id': 3,
      'title': 'Recordatorio de Vacuna',
      'message': 'Es hora de vacunar a tu mascota contra la rabia',
      'category': 'Citas',
      'time': '1 día',
      'isRead': true,
      'icon': Icons.medical_services,
      'color': AppColors.tertiary,
    },
    {
      'id': 4,
      'title': 'Actualización del Sistema',
      'message': 'Hemos mejorado la experiencia de usuario',
      'category': 'Sistema',
      'time': '2 días',
      'isRead': true,
      'icon': Icons.system_update,
      'color': AppColors.primary,
    },
    {
      'id': 5,
      'title': 'Nuevo Servicio Disponible',
      'message': 'Ahora ofrecemos servicio de peluquería canina',
      'category': 'Promociones',
      'time': '3 días',
      'isRead': true,
      'icon': Icons.pets,
      'color': AppColors.secondary,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredAlerts {
    if (_selectedCategory == 'Todas') {
      return _alerts;
    }
    return _alerts
        .where((alert) => alert['category'] == _selectedCategory)
        .toList();
  }

  void _markAsRead(int id) {
    setState(() {
      final alert = _alerts.firstWhere((a) => a['id'] == id);
      alert['isRead'] = true;
    });
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
        title: const Text('Centro de Alertas', style: TextStyles.titleText),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Category Filter
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildCategoryChip('Todas'),
                _buildCategoryChip('Citas'),
                _buildCategoryChip('Promociones'),
                _buildCategoryChip('Sistema'),
              ],
            ),
          ),

          // Alerts List
          Expanded(
            child: _filteredAlerts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay alertas',
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
                    itemCount: _filteredAlerts.length,
                    itemBuilder: (context, index) {
                      final alert = _filteredAlerts[index];
                      return _buildAlertCard(alert, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: FilterChip(
        label: Text(category),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = category;
          });
        },
        backgroundColor: Colors.white,
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.primary,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected
                ? AppColors.primary
                : AppColors.primary.withOpacity(0.3),
          ),
        ),
      ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert, int index) {
    final isRead = alert['isRead'] as bool;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRead
                ? Colors.grey.shade200
                : AppColors.primary.withOpacity(0.3),
            width: isRead ? 1 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              if (!isRead) {
                _markAsRead(alert['id']);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: (alert['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      alert['icon'] as IconData,
                      color: alert['color'] as Color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                alert['title'],
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryText,
                                ),
                              ),
                            ),
                            if (!isRead)
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          alert['message'],
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Hace ${alert['time']}',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
