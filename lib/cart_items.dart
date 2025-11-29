class CartItem {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  int quantity;
  final String description;
  final String category;
  final double rating;
  final String cuisine;
  final String spiceLevel;
  final String dietary;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
    this.description = '',
    this.category = '',
    this.rating = 0.0,
    this.cuisine = '',
    this.spiceLevel = '',
    this.dietary = '',
  });

  double get subtotal => price * quantity;

  void incrementQuantity() {
    quantity++;
  }

  void decrementQuantity() {
    if (quantity > 1) {
      quantity--;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'description': description,
      'category': category,
      'rating': rating,
      'cuisine': cuisine,
      'spiceLevel': spiceLevel,
      'dietary': dietary,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? json['image_url'] ?? '',
      quantity: json['quantity'] ?? 1,
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      cuisine: json['cuisine'] ?? '',
      spiceLevel: json['spiceLevel'] ?? json['spice_level'] ?? '',
      dietary: json['dietary'] ?? '',
    );
  }

  CartItem copyWith({
    String? id,
    String? name,
    double? price,
    String? imageUrl,
    int? quantity,
    String? description,
    String? category,
    double? rating,
    String? cuisine,
    String? spiceLevel,
    String? dietary,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
      description: description ?? this.description,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      cuisine: cuisine ?? this.cuisine,
      spiceLevel: spiceLevel ?? this.spiceLevel,
      dietary: dietary ?? this.dietary,
    );
  }
}