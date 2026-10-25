import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../providers/item_provider.dart';
import '../widgets/app_navbar.dart';
import '../widgets/category_badge.dart';

class ItemDetailScreen extends StatelessWidget {
  final String itemId;

  const ItemDetailScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    final itemProvider = context.watch<ItemProvider>();
    final item = itemProvider.getItemById(itemId);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const AppNavbar(currentRoute: '/item-detail'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Back Button
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Back to Items'),
                  ),
                ),
                const SizedBox(height: 12),

                // Availability Guard check
                if (item == null || item.isCollected) ...[
                  Card(
                    color: isDark ? const Color(0xFF451A1A) : const Color(0xFFFEF2F2),
                    child: Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 48,
                            color: Color(0xFFDC2626),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Item Not Found or Already Collected',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'This item may have already been claimed by its owner or removed from the active inventory catalog.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF7F1D1D),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () => Navigator.pushReplacementNamed(context, '/search'),
                            icon: const Icon(Icons.search_rounded),
                            label: const Text('Browse Active Inventory'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  _buildItemDetailsCard(context, item, isDark),
                  const SizedBox(height: 24),
                  _buildClaimInstructionsCard(context, isDark),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemDetailsCard(BuildContext context, Item item, bool isDark) {
    final formattedDate = DateFormat('MMMM dd, yyyy • hh:mm a').format(item.dateAdded);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Large Hero Image
          AspectRatio(
            aspectRatio: 16 / 10,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  item.photoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      child: Center(
                        child: Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  top: 14,
                  left: 14,
                  child: CategoryBadge(category: item.category),
                ),
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF059669),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_outline, size: 13, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Available',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Details content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Found location & timestamp tags
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Color(0xFFD97706),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Found at: ${item.location}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 16,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                const Text(
                  'Full Description',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),

                // Non-truncated description
                SelectableText(
                  item.description,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClaimInstructionsCard(BuildContext context, bool isDark) {
    return Card(
      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.verified_user_outlined, color: Color(0xFF1E3A8A)),
                SizedBox(width: 8),
                Text(
                  'How to Claim Your Item',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '1. Visit the Central Campus Lost & Found Office located at Student Union, Room 102.\n'
              '2. Bring a valid Student ID or official photo identification.\n'
              '3. Provide verifying details (e.g., serial number, device passcode, distinctive markings) to the desk officer.',
              style: TextStyle(fontSize: 14, height: 1.6, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            const Text(
              'Office Hours: Monday - Friday, 8:00 AM - 5:00 PM',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFFD97706),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
