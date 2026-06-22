import 'package:eClassify/utils/json_helper.dart';
import 'package:flutter/material.dart';

enum ReferralTransactionType {
  credit(Colors.green),
  debit(Colors.red);

  const ReferralTransactionType(this.color);

  final MaterialColor color;

  static ReferralTransactionType fromString(String value) {
    switch (value) {
      case "credit":
        return ReferralTransactionType.credit;
      case "debit":
        return ReferralTransactionType.debit;
      default:
        return ReferralTransactionType.credit;
    }
  }
}

class ReferralTransaction {
  ReferralTransaction.fromJson(Json json)
    : id = json['id'] as int,
      userId = json['user_id'] as int,
      points = json['points'] as int,
      transactionType = ReferralTransactionType.fromString(
        json['transaction_type'] as String,
      ),
      remark = json['remark'] as String,
      transactionDate = DateTime.parse(json['created_at'] as String);

  final int id;
  final int userId;
  final int points;
  final ReferralTransactionType transactionType;
  final String remark;
  final DateTime transactionDate;
}
