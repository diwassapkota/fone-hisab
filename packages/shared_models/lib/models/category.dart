import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';
part 'category.g.dart';

/// Product category with count
@freezed
class Category with _$Category {
  const factory Category({
    required String category,
    required int productCount,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
}

extension CategoryExtension on Category {
  /// Display name with count
  String get displayName => '$category ($productCount)';

  /// Whether category has products
  bool get hasProducts => productCount > 0;
}
