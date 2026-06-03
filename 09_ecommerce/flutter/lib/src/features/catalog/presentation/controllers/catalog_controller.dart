import 'package:flutter/foundation.dart';

import '../../../../core/config/shopify_config.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/catalog_repository.dart';

enum CatalogStatus { initial, loading, loaded, configMissing, failure }

class CatalogController extends ChangeNotifier {
  CatalogController({
    required ShopifyConfig config,
    required CatalogRepository repository,
  }) : _config = config,
       _repository = repository;

  final ShopifyConfig _config;
  final CatalogRepository _repository;

  CatalogStatus _status = CatalogStatus.initial;
  List<Product> _products = const [];
  String? _errorMessage;

  CatalogStatus get status => _status;
  List<Product> get products => _products;
  String? get errorMessage => _errorMessage;
  List<String> get missingConfigKeys => _config.missingKeys;

  Future<void> loadCatalog() async {
    if (!_config.isConfigured) {
      _status = CatalogStatus.configMissing;
      notifyListeners();
      return;
    }

    _status = CatalogStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _repository.fetchProducts();
      _status = CatalogStatus.loaded;
    } catch (error) {
      _status = CatalogStatus.failure;
      _errorMessage = error.toString();
    }

    notifyListeners();
  }
}
