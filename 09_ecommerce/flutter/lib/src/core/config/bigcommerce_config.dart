class BigCommerceConfig {
  const BigCommerceConfig({
    required this.storeHash,
    required this.channelId,
    required this.storefrontToken,
  });

  factory BigCommerceConfig.fromEnvironment() {
    return BigCommerceConfig(
      storeHash: const String.fromEnvironment('BIGCOMMERCE_STORE_HASH').trim(),
      channelId: const String.fromEnvironment('BIGCOMMERCE_CHANNEL_ID').trim(),
      storefrontToken: const String.fromEnvironment(
        'BIGCOMMERCE_STOREFRONT_TOKEN',
      ).trim(),
    );
  }

  final String storeHash;
  final String channelId;
  final String storefrontToken;

  bool get isConfigured =>
      storeHash.isNotEmpty &&
      channelId.isNotEmpty &&
      storefrontToken.isNotEmpty;

  List<String> get missingKeys {
    final keys = <String>[];

    if (storeHash.isEmpty) {
      keys.add('BIGCOMMERCE_STORE_HASH');
    }

    if (channelId.isEmpty) {
      keys.add('BIGCOMMERCE_CHANNEL_ID');
    }

    if (storefrontToken.isEmpty) {
      keys.add('BIGCOMMERCE_STOREFRONT_TOKEN');
    }

    return keys;
  }
}
