import 'package:flutter/material.dart';

import '../../../../core/config/stripe_config.dart';
import '../../../../core/presentation/pages/provider_placeholder_page.dart';

class StripeExamplePage extends StatelessWidget {
  const StripeExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    final config = StripeConfig.fromEnvironment();

    return ProviderPlaceholderPage(
      title: 'Stripe',
      status: config.isConfigured
          ? 'Configuracion detectada'
          : 'Configuracion pendiente',
      description:
          'Este ejemplo quedo preparado para integrar pagos en un feature propio, separado del catalogo y del proveedor de ecommerce.',
      nextSteps: const [
        'Agregar SDK de Stripe cuando definamos el flujo exacto.',
        'Crear backend o example server para PaymentIntent y ephemeral keys.',
        'Implementar payment sheet o elementos nativos sin acoplarlos a Shopify o BigCommerce.',
      ],
      configKeys: config.missingKeys,
    );
  }
}
