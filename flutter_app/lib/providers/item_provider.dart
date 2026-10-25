import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/item.dart';

class ItemProvider extends ChangeNotifier {
  static const String _storageKey = 'backpocket_items_data';
  static const String _apiBaseUrl = 'http://localhost:3001';

  List<Item> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  String _searchQuery = '';
  String _selectedCategory = 'All';

  List<Item> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  int get totalCount => _items.length;
  int get availableCount => _items.where((i) => i.isAvailable).length;
  int get collectedCount => _items.where((i) => i.isCollected).length;

  static final List<Item> _initialSeedItems = [
    Item(
      id: 'item-1',
      description: 'Dark blue wireless earbuds with a compact charging case.',
      location: '442 lab',
      photoUrl: 'https://i.ibb.co/27mKzQmX/Whats-App-Image-2026-09-11-at-10-17-16-AM.jpg',
      category: 'Electronics',
      dateAdded: DateTime.parse('2026-07-11T10:30:00.000Z'),
      status: 'available',
    ),
    Item(
      id: 'item-2',
      description: 'wireless mouse with a compact ergonomic design and a scroll wheel name croma.',
      location: '442 lab',
      photoUrl: 'https://i.ibb.co/4rYyXbp/Whats-App-Image-2026-09-11-at-10-17-21-AM.jpg',
      category: 'Electronics',
      dateAdded: DateTime.parse('2026-06-11T10:35:00.000Z'),
      status: 'available',
    ),
    Item(
      id: 'item-3',
      description: 'silver wristwatch with a round dial and a dark metal bracelet company peter england.',
      location: '247 lab',
      photoUrl: 'https://i.ibb.co/4R7pJ9yG/Whats-App-Image-2026-09-11-at-10-17-25-AM.jpg',
      category: 'Other',
      dateAdded: DateTime.parse('2026-01-11T10:40:00.000Z'),
      status: 'available',
    ),
    Item(
      id: 'item-4',
      description: 'Black wireless mouse with a rounded ergonomic design and a scroll wheel. Found on a desk in the lab.',
      location: '442 lab',
      photoUrl: 'https://i.ibb.co/BVYc636Z/Whats-App-Image-2026-09-11-at-10-17-53-AM.jpg',
      category: 'Electronics',
      dateAdded: DateTime.parse('2026-04-11T10:00:00.000Z'),
      status: 'available',
    ),
    Item(
      id: 'item-5',
      description: 'Silver metal wristwatch with a round skeleton-style dial, Roman numeral markers, and a metal link bracelet.',
      location: '420 classroom',
      photoUrl: 'https://i.ibb.co/xKPtj83C/Whats-App-Image-2026-09-11-at-10-17-50-AM.jpg',
      category: 'Other',
      dateAdded: DateTime.parse('2026-04-11T10:05:00.000Z'),
      status: 'available',
    ),
    Item(
      id: 'item-6',
      description: 'Set of silver keys with a pink strap and a Hello Kitty character keychain attached.',
      location: 'Parking lot',
      photoUrl: 'https://i.ibb.co/GfqZvZ6g/Whats-App-Image-2026-09-11-at-10-17-42-AM.jpg',
      category: 'Other',
      dateAdded: DateTime.parse('2026-09-11T10:10:00.000Z'),
      status: 'available',
    ),
    Item(
      id: 'item-7',
      description: 'Clear transparent-frame eyeglasses with rectangular lenses and slim arms.',
      location: 'Girls waiting room',
      photoUrl: 'https://i.ibb.co/fzf6fB4B/Whats-App-Image-2026-09-11-at-10-17-38-AM.jpg',
      category: 'Other',
      dateAdded: DateTime.parse('2026-09-11T10:15:00.000Z'),
      status: 'available',
    ),
    Item(
      id: 'item-8',
      description: 'Brown leather wallet with a compact rectangular design and multiple card slots.',
      location: 'near Basketball court',
      photoUrl: 'https://i.ibb.co/dsvprJbM/Whats-App-Image-2026-09-11-at-10-17-28-AM.jpg',
      category: 'Other',
      dateAdded: DateTime.parse('2026-08-11T10:20:00.000Z'),
      status: 'available',
    ),
    Item(
      id: 'item-9',
      description: 'Silver-colored ring with a simple polished band and a small raised detail on the top.',
      location: 'Gymnasium',
      photoUrl: 'https://i.ibb.co/MvfqtXY/Whats-App-Image-2026-09-11-at-10-17-24-AM.jpg',
      category: 'Other',
      dateAdded: DateTime.parse('2026-09-11T10:25:00.000Z'),
      status: 'available',
    ),
  ];

  ItemProvider() {
    loadItems();
  }

  Future<void> loadItems() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final localJson = prefs.getString(_storageKey);

      if (localJson != null && localJson.isNotEmpty) {
        final List decoded = jsonDecode(localJson);
        _items = decoded.map((e) => Item.fromJson(e)).toList();
      } else {
        // Attempt fetch from REST API if reachable
        try {
          final res = await http.get(Uri.parse('$_apiBaseUrl/items')).timeout(const Duration(seconds: 2));
          if (res.statusCode == 200) {
            final List data = jsonDecode(res.body);
            _items = data.map((e) => Item.fromJson(e)).toList();
            await _saveToStorage();
          } else {
            _items = List.from(_initialSeedItems);
            await _saveToStorage();
          }
        } catch (_) {
          // Fallback to initial seed items
          _items = List.from(_initialSeedItems);
          await _saveToStorage();
        }
      }
    } catch (e) {
      _items = List.from(_initialSeedItems);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_items.map((i) => i.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (_) {}
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = 'All';
    notifyListeners();
  }

  List<Item> get filteredAvailableItems {
    return _items.where((item) {
      if (!item.isAvailable) return false;

      if (_selectedCategory != 'All' && item.category.toLowerCase() != _selectedCategory.toLowerCase()) {
        return false;
      }

      if (_searchQuery.trim().isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final inDesc = item.description.toLowerCase().contains(query);
        final inLoc = item.location.toLowerCase().contains(query);
        final inCat = item.category.toLowerCase().contains(query);
        return inDesc || inLoc || inCat;
      }

      return true;
    }).toList();
  }

  Item? getItemById(String id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<bool> addItem({
    required String description,
    required String location,
    required String category,
    required String photoUrl,
  }) async {
    final newItem = Item(
      id: 'item-${DateTime.now().millisecondsSinceEpoch}',
      description: description.trim(),
      location: location.trim(),
      category: category.trim(),
      photoUrl: photoUrl.trim().isNotEmpty
          ? photoUrl.trim()
          : 'https://images.unsplash.com/photo-1584438784894-089d6a62b8fa?auto=format&fit=crop&w=600&q=80',
      dateAdded: DateTime.now(),
      status: 'available',
    );

    _items.insert(0, newItem);
    notifyListeners();
    await _saveToStorage();

    // Optionally sync with json-server in background
    try {
      http.post(
        Uri.parse('$_apiBaseUrl/items'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(newItem.toJson()),
      ).catchError((_) => http.Response('', 500));
    } catch (_) {}

    return true;
  }

  Future<void> markAsCollected(String id) async {
    final index = _items.indexWhere((i) => i.id == id);
    if (index != -1) {
      _items[index] = _items[index].copyWith(status: 'collected');
      notifyListeners();
      await _saveToStorage();

      try {
        http.patch(
          Uri.parse('$_apiBaseUrl/items/$id'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'status': 'collected'}),
        ).catchError((_) => http.Response('', 500));
      } catch (_) {}
    }
  }

  Future<void> deleteItem(String id) async {
    _items.removeWhere((i) => i.id == id);
    notifyListeners();
    await _saveToStorage();

    try {
      http.delete(
        Uri.parse('$_apiBaseUrl/items/$id'),
      ).catchError((_) => http.Response('', 500));
    } catch (_) {}
  }
}
