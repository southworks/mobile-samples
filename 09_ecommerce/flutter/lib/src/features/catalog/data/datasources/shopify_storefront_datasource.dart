import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/config/shopify_config.dart';
import '../../../../core/errors/shopify_exception.dart';
import '../models/shopify_product_model.dart';

class ShopifyStorefrontDataSource {
  ShopifyStorefrontDataSource({
    required http.Client httpClient,
    required ShopifyConfig config,
  }) : _httpClient = httpClient,
       _config = config;

  final http.Client _httpClient;
  final ShopifyConfig _config;

  static const String _productsQuery = r'''
    query GetProducts {
      products(first: 20, sortKey: BEST_SELLING) {
        edges {
          node {
            id
            title
            description
            images(first: 1) {
              edges {
                node {
                  url
                  altText
                }
              }
            }
            priceRange {
              minVariantPrice {
                amount
                currencyCode
              }
            }
          }
        }
      }
    }
  ''';

  Future<List<ShopifyProductModel>> fetchProducts() async {
    if (!_config.isConfigured) {
      throw const ShopifyException(
        'Missing Shopify configuration. Provide the required dart defines.',
      );
    }

    final response = await _httpClient.post(
      _config.storefrontApiUri,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'X-Shopify-Storefront-Access-Token': _config.storefrontAccessToken,
      },
      body: jsonEncode(<String, dynamic>{'query': _productsQuery}),
    );

    if (response.statusCode != 200) {
      throw ShopifyException(
        'Shopify request failed with status ${response.statusCode}.',
      );
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final errors = payload['errors'] as List<dynamic>?;

    if (errors != null && errors.isNotEmpty) {
      throw ShopifyException(
        errors.first['message'] as String? ?? 'Unknown Shopify error.',
      );
    }

    final productEdges =
        payload['data']?['products']?['edges'] as List<dynamic>? ?? const [];

    return productEdges
        .map(
          (edge) => ShopifyProductModel.fromJson(
            edge['node'] as Map<String, dynamic>? ?? const {},
          ),
        )
        .toList(growable: false);
  }
}
