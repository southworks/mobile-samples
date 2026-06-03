import 'package:flutter/material.dart';

import '../widgets/example_card.dart';

class ExamplesHomePage extends StatelessWidget {
  const ExamplesHomePage({
    super.key,
    required this.shopifyPageBuilder,
    required this.bigCommercePageBuilder,
    required this.stripePageBuilder,
  });

  final WidgetBuilder shopifyPageBuilder;
  final WidgetBuilder bigCommercePageBuilder;
  final WidgetBuilder stripePageBuilder;

  @override
  Widget build(BuildContext context) {
    final examples = <_ExampleDefinition>[
      _ExampleDefinition(
        title: 'Shopify',
        subtitle: 'Catalogo por Storefront API',
        description:
            'Ejemplo activo con productos, estados de carga y configuracion por dart-define.',
        onTap: () => _openExample(context, shopifyPageBuilder),
      ),
      _ExampleDefinition(
        title: 'BigCommerce',
        subtitle: 'Scaffold para Storefront API',
        description:
            'Base separada para sumar catalogo y checkout sin mezclar contratos ni credenciales.',
        onTap: () => _openExample(context, bigCommercePageBuilder),
      ),
      _ExampleDefinition(
        title: 'Stripe',
        subtitle: 'Scaffold para pagos',
        description:
            'Espacio reservado para payment sheet, intent orchestration y flujo de pago.',
        onTap: () => _openExample(context, stripePageBuilder),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Ecommerce Samples')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Ejemplos separados por proveedor',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Comparten shell de Flutter, pero cada integracion vive en su propio feature.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            for (final example in examples) ...[
              ExampleCard(
                title: example.title,
                subtitle: example.subtitle,
                description: example.description,
                onTap: example.onTap,
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  void _openExample(BuildContext context, WidgetBuilder pageBuilder) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: pageBuilder));
  }
}

class _ExampleDefinition {
  const _ExampleDefinition({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String description;
  final VoidCallback onTap;
}
