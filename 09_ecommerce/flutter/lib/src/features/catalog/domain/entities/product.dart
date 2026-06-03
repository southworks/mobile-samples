class Product {
  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.imageAltText,
    required this.price,
    required this.currencyCode,
  });

  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String? imageAltText;
  final String price;
  final String currencyCode;

  String get formattedPrice => '$currencyCode $price';
}
