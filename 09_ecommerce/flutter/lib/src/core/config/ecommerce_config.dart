import 'bigcommerce_config.dart';
import 'shopify_config.dart';
import 'stripe_config.dart';

class EcommerceConfig {
  const EcommerceConfig({
    required this.shopify,
    required this.bigCommerce,
    required this.stripe,
  });

  factory EcommerceConfig.fromEnvironment() {
    return EcommerceConfig(
      shopify: ShopifyConfig.fromEnvironment(),
      bigCommerce: BigCommerceConfig.fromEnvironment(),
      stripe: StripeConfig.fromEnvironment(),
    );
  }

  final ShopifyConfig shopify;
  final BigCommerceConfig bigCommerce;
  final StripeConfig stripe;
}
