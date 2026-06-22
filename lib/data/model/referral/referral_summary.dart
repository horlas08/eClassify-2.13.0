import 'package:eClassify/utils/json_helper.dart';

class ReferralSummary {
  ReferralSummary.fromJson(Json json)
    : referralPoints = json['refer_points'] as num? ?? 0,
      referralCode = json['referral_code'] as String,
      totalReferrals = json['total_referrals'] as num? ?? 0,
      rewardedReferrals = json['rewarded_referrals'] as num? ?? 0;

  final num referralPoints;
  final String referralCode;
  final num totalReferrals;
  final num rewardedReferrals;
}
