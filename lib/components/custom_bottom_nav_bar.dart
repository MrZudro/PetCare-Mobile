import 'package:flutter/material.dart';
import 'package:petcare/core/color_theme.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home,
                index: 0,
                isSelected: currentIndex == 0,
              ),
              _buildNavItem(
                icon: Icons.shopping_bag,
                index: 1,
                isSelected: currentIndex == 1,
              ),
              _buildNavItem(
                icon: Icons.medical_services,
                index: 2,
                isSelected: currentIndex == 2,
              ),
              _buildNavItem(
                icon: Icons.pets,
                index: 3,
                isSelected: currentIndex == 3,
              ),
              _buildNavItem(
                icon: Icons.settings,
                index: 4,
                isSelected: currentIndex == 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required int index,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.secondary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isSelected ? AppColors.secondary : Colors.grey,
          size: 28,
        ),
      ),
    );
  }
}
