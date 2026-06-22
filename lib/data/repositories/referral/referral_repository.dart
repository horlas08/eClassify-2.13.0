import 'package:eClassify/data/model/data_output.dart';
import 'package:eClassify/data/model/referral/referral_summary.dart';
import 'package:eClassify/data/model/referral/referral_transaction.dart';
import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/json_helper.dart';
import 'package:eClassify/utils/log.dart';

class ReferralRepository {
  ReferralRepository._internal();

  static final ReferralRepository _instance = ReferralRepository._internal();

  static ReferralRepository get instance => _instance;

  Future<ReferralSummary> getReferralSummary() async {
    try {
      final response = await Api.get(url: Api.referPointsBalanceApi);
      return ReferralSummary.fromJson(response['data'] as Json);
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  Future<DataOutput<ReferralTransaction>> getReferralTransactions({
    int page = 1,
  }) async {
    try {
      final response = await Api.get(
        url: Api.referPointsHistoryApi,
        queryParameters: {Api.page: page},
      );

      final transactions = JsonHelper.parseList(
        response['data']['data'] as List?,
        ReferralTransaction.fromJson,
      );
      final total = response['data']['total'] as int;

      return DataOutput(total: total, modelList: transactions);
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }
}
