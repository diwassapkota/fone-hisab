import 'package:shared_models/shared_models.dart';
import '../config/api_config.dart';
import 'dio_client.dart';

class ProductService {
  final DioClient _dioClient;

  ProductService(this._dioClient);

  /// Get paginated list of products with filters
  Future<ApiResponse<Map<String, dynamic>>> getProducts({
    int page = 0,
    int size = 20,
    String? search,
    String? category,
    bool? inStock,
    bool? lowStock,
    String sortBy = 'RECENT', // RECENT, NAME_ASC, NAME_DESC, PRICE_LOW, PRICE_HIGH, STOCK_LOW, STOCK_HIGH
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'size': size.toString(),
        'sortBy': sortBy,
        if (search != null && search.isNotEmpty) 'search': search,
        if (category != null) 'category': category,
        if (inStock != null) 'inStock': inStock.toString(),
        if (lowStock != null) 'lowStock': lowStock.toString(),
      };

      final response = await _dioClient.get(
        ApiConfig.products,
        queryParameters: queryParams,
      );

      return ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get product by ID
  Future<ApiResponse<Product>> getProductById(String productId) async {
    try {
      final response = await _dioClient.get(
        ApiConfig.productById(productId),
      );

      return ApiResponse<Product>.fromJson(
        response.data,
        (json) => Product.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get product by barcode
  Future<ApiResponse<Product>> getProductByBarcode(String barcode) async {
    try {
      final response = await _dioClient.get(
        ApiConfig.productByBarcode(barcode),
      );

      return ApiResponse<Product>.fromJson(
        response.data,
        (json) => Product.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get product by SKU
  Future<ApiResponse<Product>> getProductBySku(String sku) async {
    try {
      final response = await _dioClient.get(
        ApiConfig.productBySku(sku),
      );

      return ApiResponse<Product>.fromJson(
        response.data,
        (json) => Product.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Create new product
  Future<ApiResponse<Product>> createProduct({
    required String productName,
    String? description,
    String? category,
    String? sku,
    String? barcode,
    required double costPrice,
    required double sellingPrice,
    bool trackInventory = true,
    int stockQuantity = 0,
    int minStockLevel = 0,
    String unit = 'PCS',
    bool isActive = true,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConfig.products,
        data: {
          'productName': productName,
          if (description != null) 'description': description,
          if (category != null) 'category': category,
          if (sku != null) 'sku': sku,
          if (barcode != null) 'barcode': barcode,
          'costPrice': costPrice,
          'sellingPrice': sellingPrice,
          'trackInventory': trackInventory,
          'stockQuantity': stockQuantity,
          'minStockLevel': minStockLevel,
          'unit': unit,
          'isActive': isActive,
        },
      );

      return ApiResponse<Product>.fromJson(
        response.data,
        (json) => Product.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Update existing product
  Future<ApiResponse<Product>> updateProduct({
    required String productId,
    String? productName,
    String? description,
    String? category,
    String? sku,
    String? barcode,
    double? costPrice,
    double? sellingPrice,
    int? minStockLevel,
    String? unit,
    bool? isActive,
  }) async {
    try {
      final response = await _dioClient.put(
        ApiConfig.productById(productId),
        data: {
          if (productName != null) 'productName': productName,
          if (description != null) 'description': description,
          if (category != null) 'category': category,
          if (sku != null) 'sku': sku,
          if (barcode != null) 'barcode': barcode,
          if (costPrice != null) 'costPrice': costPrice,
          if (sellingPrice != null) 'sellingPrice': sellingPrice,
          if (minStockLevel != null) 'minStockLevel': minStockLevel,
          if (unit != null) 'unit': unit,
          if (isActive != null) 'isActive': isActive,
        },
      );

      return ApiResponse<Product>.fromJson(
        response.data,
        (json) => Product.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Delete product
  Future<ApiResponse<Map<String, dynamic>>> deleteProduct(
      String productId) async {
    try {
      final response = await _dioClient.delete(
        ApiConfig.productById(productId),
      );

      return ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Manually adjust stock (add or remove)
  Future<ApiResponse<Map<String, dynamic>>> adjustStock({
    required String productId,
    required String adjustmentType, // ADD, REMOVE
    required int quantity,
    required String reason,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConfig.adjustStock(productId),
        data: {
          'adjustmentType': adjustmentType,
          'quantity': quantity,
          'reason': reason,
        },
      );

      return ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get low stock products
  Future<ApiResponse<Map<String, dynamic>>> getLowStockProducts({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'size': size.toString(),
      };

      final response = await _dioClient.get(
        ApiConfig.lowStockProducts,
        queryParameters: queryParams,
      );

      return ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get product categories with counts
  Future<ApiResponse<List<Category>>> getCategories() async {
    try {
      final response = await _dioClient.get(
        ApiConfig.productCategories,
      );

      return ApiResponse<List<Category>>.fromJson(
        response.data,
        (json) {
          final dataList = json as List;
          return dataList
              .map((item) => Category.fromJson(item as Map<String, dynamic>))
              .toList();
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}
