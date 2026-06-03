import '../../domain/entities/product.dart';

class ShopifyProductModel extends Product {
  const ShopifyProductModel({
    required super.id,
    required super.title,
    required super.description,
    required super.imageUrl,
    required super.imageAltText,
    required super.price,
    required super.currencyCode,
  });

  factory ShopifyProductModel.fromJson(Map<String, dynamic> json) {
    final imageEdges = (json['images']?['edges'] as List<dynamic>? ?? const []);
    final imageNode = imageEdges.isEmpty
        ? null
        : imageEdges.first['node'] as Map<String, dynamic>?;
    final minVariantPrice =
        json['priceRange']?['minVariantPrice'] as Map<String, dynamic>? ?? {};

    return ShopifyProductModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: imageNode?['url'] as String?,
      imageAltText: imageNode?['altText'] as String?,
      price: minVariantPrice['amount'] as String? ?? '0.00',
      currencyCode: minVariantPrice['currencyCode'] as String? ?? '',
    );
  }
}
