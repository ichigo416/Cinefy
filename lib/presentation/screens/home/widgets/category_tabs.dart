import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';

class CategoryTab {
  final String label;
  final IconData icon;
  const CategoryTab({required this.label, required this.icon});
}

const List<CategoryTab> kCategories = [
  CategoryTab(label: 'Movies', icon: Icons.movie_outlined),
  CategoryTab(label: 'Events', icon: Icons.celebration_outlined),
  CategoryTab(label: 'Plays', icon: Icons.theater_comedy_outlined),
  CategoryTab(label: 'Sports', icon: Icons.sports_soccer_outlined),
  CategoryTab(label: 'Activities', icon: Icons.local_activity_outlined),
];

class CategoryTabs extends StatefulWidget {
  final void Function(int index) onCategoryChanged;

  const CategoryTabs({super.key, required this.onCategoryChanged});

  @override
  State<CategoryTabs> createState() => _CategoryTabsState();
}

class _CategoryTabsState extends State<CategoryTabs> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: kCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => _CategoryChip(
          tab: kCategories[i],
          isSelected: _selected == i,
          onTap: () {
            setState(() => _selected = i);
            widget.onCategoryChanged(i);
          },
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final CategoryTab tab;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.15)
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              tab.icon,
              size: 20,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              tab.label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 