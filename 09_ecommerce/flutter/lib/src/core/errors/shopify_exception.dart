class ShopifyException implements Exception {
  const ShopifyException(this.message);

  final String message;

  @override
  String toString() => message;
}
