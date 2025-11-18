import 'package:freezed_annotation/freezed_annotation.dart';

part 'merchant.freezed.dart';
part 'merchant.g.dart';

@freezed
class Merchant with _$Merchant {
  const factory Merchant({
    required String id,
    required String name,
    required String businessName,
    required String phoneNumber,
    String? email,
    String? address,
    String? panNumber,
    String? profileImageUrl,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Merchant;

  factory Merchant.fromJson(Map<String, dynamic> json) =>
      _$MerchantFromJson(json);
}
