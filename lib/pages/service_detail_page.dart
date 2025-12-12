import 'package:flutter/material.dart';
import 'package:petcare/models/service_model.dart';
import 'package:petcare/core/color_theme.dart';
import 'package:petcare/core/text_styles.dart';

class ServiceDetailPage extends StatelessWidget {
  final ServiceModel service;

  const ServiceDetailPage({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detalle del Servicio',
          style: TextStyles.titleText.copyWith(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service Image
              Container(
                height: 280,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: service.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          service.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.medical_services,
                                size: 64,
                                color: Colors.grey.shade300,
                              ),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.medical_services,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                      ),
              ),
              const SizedBox(height: 24),

              // Service Title
              Text(
                service.name,
                style: TextStyles.bodyTextBlack.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),

              // Veterinary
              if (service.veterinary != null)
                Row(
                  children: [
                    const Icon(
                      Icons.store_mall_directory_outlined,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      service.veterinary!,
                      style: TextStyles.bodyTextBlack.copyWith(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24),

              // Description
              Text(
                'Descripción',
                style: TextStyles.bodyTextBlack.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                service.description.isNotEmpty
                    ? service.description
                    : 'Servicio veterinario profesional para el cuidado de tu mascota.',
                style: TextStyles.bodyTextBlack.copyWith(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 48),

              // Schedule Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Agendar cita... Próximamente'),
                        backgroundColor: AppColors.secondary,
                      ),
                    );
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    'Agendar Servicio',
                    style: TextStyles.bodyTextBlack.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
