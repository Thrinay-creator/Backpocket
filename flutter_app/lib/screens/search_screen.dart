import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../providers/item_provider.dart';
import '../widgets/app_navbar.dart';
import '../widgets/category_badge.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _categories = [
    'All',
    'Electronics',
    'ID Cards',
    'Bags',
    'Books',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    final itemProvider = context.read<ItemProvider>();
    _searchController.text = itemProvider.searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemProvider = context.watch<ItemProvider>();
    final items = itemProvider.filteredAvailableItems;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const AppNavbar(currentRoute: '/search'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Search & Filter Header Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Search Input Field
                        TextField(
                          controller: _searchController,
                          onChanged: (val) {
                            itemProvider.setSearchQuery(val);
                          },
                          decoration: InputDecoration(
                            hintText: 'Search items by keywords, color, or location...',
                            prefixIcon: const Icon(Icons.search_rounded),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded),
                                    onPressed: () {
                                      _searchController.clear();
                                      itemProvider.setSearchQuery('');
                                    },
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Category Chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _categories.map((category) {
                              final isSelected = itemProvider.selectedCategory.toLowerCase() ==
                                  category.toLowerCase();
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: CategoryBadge(
                                  category: category,
                                  isSelected: isSelected,
                                  onTap: () {
                                    itemProvider.setSelectedCategory(category);
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Results Counter & Clear action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${items.length} item${items.length == 1 ? '' : 's'} available',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                      ),
                    ),
                    if (itemProvider.searchQuery.isNotEmpty || itemProvider.selectedCategory != 'All')
                      TextButton.icon(
                        onPressed: () {
                          _searchController.clear();
                          itemProvider.clearFilters();
                        },
                        icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
                        label: const Text('Clear Filters'),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Items Content
                if (itemProvider.isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (items.isEmpty)
                  _buildEmptyState(context, itemProvider)
                else
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 650;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isWide ? 2 : 1,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: isWide ? 1.45 : 1.15,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return _buildItemCard(context, items[index]);
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, Item item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formattedDate = DateFormat('MMM dd, yyyy').format(item.dateAdded);

    // Truncate description to 60 characters with ellipses
    final truncatedDesc = item.description.length > 60
        ? '${item.description.substring(0, 60)}...'
        : item.description;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/item-detail',
            arguments: item.id,
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image preview
            Expanded(
              flex: 5,
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
                            size: 40,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: CategoryBadge(category: item.category),
                  ),
                ],
              ),
            ),

            // Card Body
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      truncatedDesc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        height: 1.3,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: Color(0xFFD97706),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item.location,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
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

  Widget _buildEmptyState(BuildContext context, ItemProvider itemProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.blueGrey.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 36,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No items match your criteria',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your search terms or clearing selected category filters.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                _searchController.clear();
                itemProvider.clearFilters();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reset All Filters'),
            ),
          ],
        ),
      ),
    );
  }
}
