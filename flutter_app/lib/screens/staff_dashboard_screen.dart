import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../providers/auth_provider.dart';
import '../providers/item_provider.dart';
import '../widgets/app_navbar.dart';
import '../widgets/category_badge.dart';

class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _photoUrlController = TextEditingController();
  String _selectedCategory = 'Electronics';
  bool _isSubmitting = false;
  bool _showSuccessView = false;
  String _tagFeedback = '';

  // Preset sample photos for easy logging
  final List<Map<String, String>> _samplePhotos = [
    {
      'label': 'Earbuds',
      'category': 'Electronics',
      'url': 'https://i.ibb.co/27mKzQmX/Whats-App-Image-2026-09-11-at-10-17-16-AM.jpg',
    },
    {
      'label': 'Wristwatch',
      'category': 'Other',
      'url': 'https://i.ibb.co/4R7pJ9yG/Whats-App-Image-2026-09-11-at-10-17-25-AM.jpg',
    },
    {
      'label': 'Keys',
      'category': 'Other',
      'url': 'https://i.ibb.co/GfqZvZ6g/Whats-App-Image-2026-09-11-at-10-17-42-AM.jpg',
    },
    {
      'label': 'Glasses',
      'category': 'Other',
      'url': 'https://i.ibb.co/fzf6fB4B/Whats-App-Image-2026-09-11-at-10-17-38-AM.jpg',
    },
    {
      'label': 'Wallet',
      'category': 'Other',
      'url': 'https://i.ibb.co/dsvprJbM/Whats-App-Image-2026-09-11-at-10-17-28-AM.jpg',
    },
  ];

  // Inventory filter state
  String _inventoryFilter = 'all'; // 'all', 'available', 'collected'
  final TextEditingController _inventorySearch = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _photoUrlController.dispose();
    _inventorySearch.dispose();
    super.dispose();
  }

  void _suggestAutoTag() {
    final text = '${_descController.text} ${_locationController.text}'.toLowerCase();
    String detected = 'Other';

    if (text.contains('phone') ||
        text.contains('earbud') ||
        text.contains('mouse') ||
        text.contains('laptop') ||
        text.contains('charger') ||
        text.contains('headphone') ||
        text.contains('cable') ||
        text.contains('electronic')) {
      detected = 'Electronics';
    } else if (text.contains('id') ||
        text.contains('card') ||
        text.contains('badge') ||
        text.contains('license') ||
        text.contains('student id')) {
      detected = 'ID Cards';
    } else if (text.contains('bag') ||
        text.contains('backpack') ||
        text.contains('purse') ||
        text.contains('pouch') ||
        text.contains('tote')) {
      detected = 'Bags';
    } else if (text.contains('book') ||
        text.contains('notebook') ||
        text.contains('textbook') ||
        text.contains('folder') ||
        text.contains('binder')) {
      detected = 'Books';
    }

    setState(() {
      _selectedCategory = detected;
      _tagFeedback = 'Auto-detected category: $detected';
    });
  }

  Future<void> _handleSubmitItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final itemProvider = context.read<ItemProvider>();
    await itemProvider.addItem(
      description: _descController.text,
      location: _locationController.text,
      category: _selectedCategory,
      photoUrl: _photoUrlController.text,
    );

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _showSuccessView = true;
      });
    }
  }

  void _resetForm() {
    setState(() {
      _descController.clear();
      _locationController.clear();
      _photoUrlController.clear();
      _selectedCategory = 'Electronics';
      _showSuccessView = false;
      _tagFeedback = '';
    });
  }

  Future<void> _confirmDelete(BuildContext context, Item item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text(
          'Are you sure you want to permanently delete this item?\n\n"${item.description.length > 50 ? '${item.description.substring(0, 50)}...' : item.description}"',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<ItemProvider>().deleteItem(item.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item deleted successfully.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final itemProvider = context.watch<ItemProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Route guard check
    if (!authProvider.isStaff) {
      return Scaffold(
        appBar: const AppNavbar(currentRoute: '/staff/dashboard'),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline_rounded, size: 54, color: Color(0xFFD97706)),
                const SizedBox(height: 16),
                const Text(
                  'Staff Authentication Required',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please sign in with your staff access code to view the desk portal.',
                  style: TextStyle(color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/staff/login'),
                  icon: const Icon(Icons.login_rounded),
                  label: const Text('Go to Staff Login'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: const AppNavbar(currentRoute: '/staff/dashboard'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Dashboard Header & Logout
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Staff Desk Portal',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                        ),
                        Text(
                          'Authorized Campus Lost & Found Desk',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await authProvider.logout();
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(context, '/');
                        }
                      },
                      icon: const Icon(Icons.logout_rounded, size: 18),
                      label: const Text('Logout'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Live Stats Ribbon
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        label: 'Total Items',
                        count: itemProvider.totalCount,
                        color: const Color(0xFF1E3A8A),
                        icon: Icons.inventory_2_rounded,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricTile(
                        label: 'Available',
                        count: itemProvider.availableCount,
                        color: const Color(0xFF059669),
                        icon: Icons.check_circle_rounded,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricTile(
                        label: 'Collected',
                        count: itemProvider.collectedCount,
                        color: const Color(0xFFD97706),
                        icon: Icons.archive_rounded,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Tabs: "Active Inventory" and "Log New Found Item"
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.list_alt_rounded),
                        text: 'Manage Inventory',
                      ),
                      Tab(
                        icon: Icon(Icons.add_circle_outline_rounded),
                        text: 'Log Found Item',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Tab Content
                AnimatedBuilder(
                  animation: _tabController,
                  builder: (context, _) {
                    if (_tabController.index == 0) {
                      return _buildInventoryTab(context, itemProvider, isDark);
                    } else {
                      return _buildLogItemTab(context, isDark);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required int count,
    required Color color,
    required IconData icon,
    required bool isDark,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count.toString(),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryTab(BuildContext context, ItemProvider itemProvider, bool isDark) {
    // Filter inventory list
    final query = _inventorySearch.text.trim().toLowerCase();
    final filtered = itemProvider.items.where((item) {
      if (_inventoryFilter == 'available' && !item.isAvailable) return false;
      if (_inventoryFilter == 'collected' && !item.isCollected) return false;

      if (query.isNotEmpty) {
        final matchesDesc = item.description.toLowerCase().contains(query);
        final matchesLoc = item.location.toLowerCase().contains(query);
        final matchesCat = item.category.toLowerCase().contains(query);
        return matchesDesc || matchesLoc || matchesCat;
      }
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Controls Row: Search & Status Filters
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _inventorySearch,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Filter inventory by description or location...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _inventorySearch.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _inventorySearch.clear();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildFilterChoiceChip('All (${itemProvider.totalCount})', 'all'),
                    const SizedBox(width: 8),
                    _buildFilterChoiceChip('Available (${itemProvider.availableCount})', 'available'),
                    const SizedBox(width: 8),
                    _buildFilterChoiceChip('Collected (${itemProvider.collectedCount})', 'collected'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        if (filtered.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40.0),
            child: Center(
              child: Text(
                'No items found matching the selected filters.',
                style: TextStyle(fontSize: 15, color: Color(0xFF64748B)),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = filtered[index];
              return _buildInventoryRow(context, item, isDark);
            },
          ),
      ],
    );
  }

  Widget _buildFilterChoiceChip(String label, String value) {
    final isSelected = _inventoryFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _inventoryFilter = value;
          });
        }
      },
    );
  }

  Widget _buildInventoryRow(BuildContext context, Item item, bool isDark) {
    final formattedDate = DateFormat('MMM dd, yyyy').format(item.dateAdded);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 70,
                height: 70,
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                child: Image.network(
                  item.photoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported_outlined),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Item Information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CategoryBadge(category: item.category),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: item.isAvailable
                              ? const Color(0xFF059669).withAlpha(25)
                              : const Color(0xFFD97706).withAlpha(25),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: item.isAvailable
                                ? const Color(0xFF059669).withAlpha(80)
                                : const Color(0xFFD97706).withAlpha(80),
                          ),
                        ),
                        child: Text(
                          item.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: item.isAvailable
                                ? const Color(0xFF059669)
                                : const Color(0xFFD97706),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 13, color: Color(0xFFD97706)),
                      const SizedBox(width: 3),
                      Text(
                        item.location,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.calendar_today_outlined, size: 12, color: Color(0xFF64748B)),
                      const SizedBox(width: 3),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Action Buttons
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (item.isAvailable)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () async {
                      await context.read<ItemProvider>().markAsCollected(item.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Item marked as collected!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.check_circle_outline, size: 16),
                    label: const Text('Mark Collected'),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inventory_rounded, size: 14, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          'Archived',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 6),
                IconButton(
                  tooltip: 'Delete Item',
                  onPressed: () => _confirmDelete(context, item),
                  icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626), size: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogItemTab(BuildContext context, bool isDark) {
    if (_showSuccessView) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFECFDF5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 44,
                  color: Color(0xFF059669),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Found Item Logged Successfully!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF059669),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'The item is now immediately available in the public directory for students to view and claim.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _resetForm,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Log Another Item'),
                  ),
                  const SizedBox(width: 14),
                  OutlinedButton.icon(
                    onPressed: () {
                      _resetForm();
                      _tabController.animateTo(0);
                    },
                    icon: const Icon(Icons.inventory_2_outlined),
                    label: const Text('View All Inventory'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Catalog Newly Turned-In Property',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Fill out the item details to make it searchable in the student lost & found catalog.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 24),

              // Item Description
              TextFormField(
                controller: _descController,
                maxLines: 3,
                maxLength: 400,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a description for the item.';
                  }
                  if (val.trim().length < 5) {
                    return 'Description must be at least 5 characters.';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Detailed Description *',
                  hintText: 'e.g. Navy blue Sony noise-cancelling headphones found on study desk.',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),

              // Location Found
              TextFormField(
                controller: _locationController,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter where the item was found.';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Campus Location Found *',
                  hintText: 'e.g. Library 2nd Floor, Room 442 Lab, Gymnasium',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 16),

              // Category Selector with AI Auto-Tag Suggestion
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Item Category *',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  TextButton.icon(
                    onPressed: _suggestAutoTag,
                    icon: const Icon(Icons.auto_awesome, size: 15, color: Color(0xFFD97706)),
                    label: const Text(
                      'AI Suggest Category',
                      style: TextStyle(fontSize: 13, color: Color(0xFFD97706)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                items: ['Electronics', 'ID Cards', 'Bags', 'Books', 'Other']
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedCategory = val;
                      _tagFeedback = '';
                    });
                  }
                },
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category_outlined),
                ),
              ),

              if (_tagFeedback.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  _tagFeedback,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF059669),
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // Photo URL & Preset Photos
              TextFormField(
                controller: _photoUrlController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Photo URL (Optional)',
                  hintText: 'https://... or choose a sample preset below',
                  prefixIcon: const Icon(Icons.photo_camera_outlined),
                  suffixIcon: _photoUrlController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _photoUrlController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 10),

              // Sample Presets
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    'Sample Presets:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                  ),
                  ..._samplePhotos.map((preset) {
                    return ActionChip(
                      label: Text(preset['label']!),
                      onPressed: () {
                        setState(() {
                          _photoUrlController.text = preset['url']!;
                          _selectedCategory = preset['category']!;
                        });
                      },
                    );
                  }),
                ],
              ),

              // Photo preview if URL provided
              if (_photoUrlController.text.trim().isNotEmpty) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 160,
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    child: Image.network(
                      _photoUrlController.text.trim(),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Text('Invalid image URL preview'),
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // Submit Button (Debounced / Disabled during submit to prevent duplicate logging)
              ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _handleSubmitItem,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.cloud_upload_outlined),
                label: Text(_isSubmitting ? 'Submitting Item...' : 'Log Found Item into Registry'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
