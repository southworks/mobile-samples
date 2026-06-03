import '../../domain/entities/product.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../datasources/shopify_storefront_datasource.dart';

class ShopifyCatalogRepository implements CatalogRepository {
  ShopifyCatalogRepository({required ShopifyStorefrontDataSource dataSource})
    : _dataSource = dataSource;

  final ShopifyStorefrontDataSource _dataSource;

  @override
  Future<List<Product>> fetchProducts() => _dataSource.fetchProducts();
}
