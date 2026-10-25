import 'package:flutter/material.dart';

class CategoryBadge extends StatelessWidget {
  final String category;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryBadge({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onTap,
  });

  Color _getBadgeColor(BuildContext context) {
    switch (category.toLowerCase()) {
      case 'electronics':
        return Colors.blue;
      case 'id cards':
        return Colors.indigo;
      case 'bags':
        return Colors.amber.shade700;
      case 'books':
        return Colors.teal;
      case 'other':
      default:
        return Colors.blueGrey;
    }
  }

  IconData _getCategoryIcon() {
    switch (category.toLowerCase()) {
      case 'electronics':
        return Icons.devices_rounded;
      case 'id cards':
        return Icons.badge_outlined;
      case 'bags':
        return Icons.backpack_outlined;
      case 'books':
        return Icons.menu_book_rounded;
      case 'other':
      default:
        return Icons.category_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getBadgeColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final badgeWidget = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected
            ? color
            : (isDark ? color.withAlpha(40) : color.withAlpha(25)),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? color : color.withAlpha(80),
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getCategoryIcon(),
            size: 15,
            color: isSelected ? Colors.white : color,
          ),
          const SizedBox(width: 6),
          Text(
            category,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : color,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: badgeWidget,
      );
    }

    return badgeWidget;
  }
}
