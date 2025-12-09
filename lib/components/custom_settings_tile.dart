import 'package:flutter/material.dart';
import 'package:petcare/core/color_theme.dart';
import 'package:petcare/core/text_styles.dart';

class CustomSettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback? onTap;
  final bool showArrow;
  final Color? iconColor;
  final Widget? trailing;

  const CustomSettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.value,
    this.onTap,
    this.showArrow = true,
    this.iconColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.transparent, // Or a light background if needed
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.primaryText, size: 24),
      ),
      title: Text(
        title,
        style: TextStyles.bodyTextBlack.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            Text(
              value!,
              style: TextStyles.bodyTextBlack.copyWith(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          if (showArrow) ...[
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.tertiary,
            ),
          ],
        ],
      ),
    );
  }
}
