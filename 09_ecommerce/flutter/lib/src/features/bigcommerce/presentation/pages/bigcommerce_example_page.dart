import 'package:flutter/material.dart';

import '../../../../core/config/bigcommerce_config.dart';
import '../../../../core/presentation/pages/provider_placeholder_page.dart';

class BigCommerceExamplePage extends StatelessWidget {
  const BigCommerceExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    final config = BigCommerceConfig.fromEnvironment();

    return ProviderPlaceholderPage(
      title: 'BigCommerce',
      status: config.isConfigured
          ? 'Configuracion detectada'
          : 'Configuracion pendiente',
      description:
          'Este ejemplo quedo preparado como feature separado para sumar catalogo, carrito y checkout usando las APIs de BigCommerce.',
      nextSteps: const [
        'Crear datasource propio para catalogo.',
        'Agregar repository y entidades del dominio BigCommerce.',
        'Conectar storefront token y channel de forma aislada.',
      ],
      configKeys: config.missingKeys,
    );
  }
}
