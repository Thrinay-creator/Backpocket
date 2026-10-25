class Item {
  final String id;
  final String description;
  final String location;
  final String photoUrl;
  final String category;
  final DateTime dateAdded;
  final String status; // 'available' or 'collected'

  Item({
    required this.id,
    required this.description,
    required this.location,
    required this.photoUrl,
    required this.category,
    required this.dateAdded,
    this.status = 'available',
  });

  bool get isAvailable => status.toLowerCase() == 'available';
  bool get isCollected => status.toLowerCase() == 'collected';

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      photoUrl: json['photoUrl']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Other',
      dateAdded: json['dateAdded'] != null
          ? DateTime.tryParse(json['dateAdded'].toString()) ?? DateTime.now()
          : DateTime.now(),
      status: json['status']?.toString() ?? 'available',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'location': location,
      'photoUrl': photoUrl,
      'category': category,
      'dateAdded': dateAdded.toIso8601String(),
      'status': status,
    };
  }

  Item copyWith({
    String? id,
    String? description,
    String? location,
    String? photoUrl,
    String? category,
    DateTime? dateAdded,
    String? status,
  }) {
    return Item(
      id: id ?? this.id,
      description: description ?? this.description,
      location: location ?? this.location,
      photoUrl: photoUrl ?? this.photoUrl,
      category: category ?? this.category,
      dateAdded: dateAdded ?? this.dateAdded,
      status: status ?? this.status,
    );
  }
}
