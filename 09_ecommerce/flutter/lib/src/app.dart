import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'core/config/ecommerce_config.dart';
import 'features/bigcommerce/presentation/pages/bigcommerce_example_page.dart';
import 'features/catalog/data/datasources/shopify_storefront_datasource.dart';
import 'features/catalog/data/repositories/shopify_catalog_repository.dart';
import 'features/catalog/presentation/controllers/catalog_controller.dart';
import 'features/home/presentation/pages/examples_home_page.dart';
import 'features/stripe/presentation/pages/stripe_example_page.dart';
import 'features/shopify/presentation/pages/shopify_example_page.dart';

class EcommerceApp extends StatefulWidget {
  const EcommerceApp({super.key});

  @override
  State<EcommerceApp> createState() => _EcommerceAppState();
}

class _EcommerceAppState extends State<EcommerceApp> {
  late final http.Client _httpClient;
  late final CatalogController _shopifyCatalogController;

  @override
  void initState() {
    super.initState();

    final config = EcommerceConfig.fromEnvironment();
    _httpClient = http.Client();

    final dataSource = ShopifyStorefrontDataSource(
      httpClient: _httpClient,
      config: config.shopify,
    );
    final repository = ShopifyCatalogRepository(dataSource: dataSource);

    _shopifyCatalogController = CatalogController(
      config: config.shopify,
      repository: repository,
    )..loadCatalog();
  }

  @override
  void dispose() {
    _httpClient.close();
    _shopifyCatalogController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ecommerce Samples',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F766E),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7F2),
      ),
      home: ExamplesHomePage(
        shopifyPageBuilder: (context) =>
            ShopifyExamplePage(controller: _shopifyCatalogController),
        bigCommercePageBuilder: (context) => const BigCommerceExamplePage(),
        stripePageBuilder: (context) => const StripeExamplePage(),
      ),
    );
  }
}
