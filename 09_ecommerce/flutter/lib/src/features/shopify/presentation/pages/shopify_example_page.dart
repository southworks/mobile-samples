import 'package:flutter/material.dart';

import '../../../catalog/presentation/controllers/catalog_controller.dart';
import '../../../catalog/presentation/pages/catalog_page.dart';

class ShopifyExamplePage extends StatelessWidget {
  const ShopifyExamplePage({super.key, required this.controller});

  final CatalogController controller;

  @override
  Widget build(BuildContext context) {
    return CatalogPage(controller: controller);
  }
}
