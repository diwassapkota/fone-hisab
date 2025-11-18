import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/dispute_status.dart';

part 'dispute.freezed.dart';
part 'dispute.g.dart';

@freezed
class Dispute with _$Dispute {
  const factory Dispute({
    required String id,
    required String transactionId,
    required String customerId,
    required String merchantId,
    required String reason,
    String? customerNotes,
    String? merchantNotes,
    required DisputeStatus status,
    required DateTime createdAt,
    DateTime? resolvedAt,
    DateTime? updatedAt,
  }) = _Dispute;

  factory Dispute.fromJson(Map<String, dynamic> json) =>
      _$DisputeFromJson(json);
}
