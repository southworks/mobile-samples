class ShopifyConfig {
  const ShopifyConfig({
    required this.shopDomain,
    required this.storefrontAccessToken,
    required this.apiVersion,
  });

  factory ShopifyConfig.fromEnvironment() {
    return ShopifyConfig(
      shopDomain: _normalizeShopDomain(
        const String.fromEnvironment('SHOPIFY_SHOP_DOMAIN'),
      ),
      storefrontAccessToken: const String.fromEnvironment(
        'SHOPIFY_STOREFRONT_ACCESS_TOKEN',
      ).trim(),
      apiVersion: const String.fromEnvironment(
        'SHOPIFY_API_VERSION',
        defaultValue: '2025-10',
      ),
    );
  }

  final String shopDomain;
  final String storefrontAccessToken;
  final String apiVersion;

  bool get isConfigured =>
      shopDomain.trim().isNotEmpty && storefrontAccessToken.trim().isNotEmpty;

  List<String> get missingKeys {
    final keys = <String>[];

    if (shopDomain.trim().isEmpty) {
      keys.add('SHOPIFY_SHOP_DOMAIN');
    }

    if (storefrontAccessToken.trim().isEmpty) {
      keys.add('SHOPIFY_STOREFRONT_ACCESS_TOKEN');
    }

    return keys;
  }

  Uri get storefrontApiUri =>
      Uri.https(shopDomain, '/api/$apiVersion/graphql.json');

  static String _normalizeShopDomain(String value) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      return '';
    }

    final uri = Uri.tryParse(trimmed);

    if (uri != null && uri.host.isNotEmpty) {
      return uri.host.trim();
    }

    return trimmed
        .replaceFirst(RegExp(r'^https?://'), '')
        .replaceAll(RegExp(r'/$'), '')
        .trim();
  }
}
