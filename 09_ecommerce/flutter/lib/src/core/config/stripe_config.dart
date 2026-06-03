class StripeConfig {
  const StripeConfig({
    required this.publishableKey,
    required this.merchantIdentifier,
  });

  factory StripeConfig.fromEnvironment() {
    return StripeConfig(
      publishableKey: const String.fromEnvironment(
        'STRIPE_PUBLISHABLE_KEY',
      ).trim(),
      merchantIdentifier: const String.fromEnvironment(
        'STRIPE_MERCHANT_IDENTIFIER',
      ).trim(),
    );
  }

  final String publishableKey;
  final String merchantIdentifier;

  bool get isConfigured => publishableKey.isNotEmpty;

  List<String> get missingKeys {
    final keys = <String>[];

    if (publishableKey.isEmpty) {
      keys.add('STRIPE_PUBLISHABLE_KEY');
    }

    if (merchantIdentifier.isEmpty) {
      keys.add('STRIPE_MERCHANT_IDENTIFIER');
    }

    return keys;
  }
}
