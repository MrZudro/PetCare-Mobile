import 'package:flutter/material.dart';
import 'package:petcare/models/service_model.dart';
import 'package:petcare/core/color_theme.dart';
import 'package:petcare/core/text_styles.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onTap;

  const ServiceCard({Key? key, required this.service, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Genera colores aleatorios para las tarjetas
    final colors = [
      AppColors.accentOne,
      AppColors.accentTwo,
      AppColors.accentThree,
    ];
    final cardColor = colors[service.id % colors.length];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Imagen
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: service.imageUrl != null
                    ? Colors.grey.shade100
                    : cardColor.withOpacity(0.5),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                image: service.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(service.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: service.imageUrl == null
                  ? const Center(
                      child: Icon(
                        Icons.medical_services,
                        size: 40,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            // Contenido de la tarjeta
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyles.bodyTextBlack.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (service.veterinary != null)
                      Text(
                        service.veterinary!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.bodyTextBlack.copyWith(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
