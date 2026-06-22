import 'dart:io';

import 'package:collection/collection.dart';
import 'package:eClassify/data/model/version.dart';
import 'package:eClassify/utils/json_helper.dart';

class SystemSettings {
  SystemSettings.fromJson(Json json)
    : demoMode = json['demo_mode'] as bool,
      version = _platformResolver(
        json['android_version'] as String,
        json['ios_version'] as String,
        Version.fromString,
      ),
      defaultLanguageCode = json['default_language'] as String,
      currentLanguageCode = json['current_language'] as String,
      forceUpdate = (json['force_update'] as String?) == '1',
      maintenanceMode = (json['maintenance_mode'] as String?) == '1',
      isFreeAdListingEnabled = (json['free_ad_listing'] as String?) == '1',
      otpProvider = json['otp_service_provider'] as String,
      mapProvider = json['map_provider'] as String,
      currencySymbol = json['currency_symbol'] as String,
      currencyIsoCode = json['currency_iso_code'] as String,
      currencyPosition = json['currency_symbol_position'] as String,
      _isBannerAdEnabled = (json['banner_ad_status'] as String?) == '1',
      bannerAdId = _platformResolver(
        json['banner_ad_id_android'] as String?,
        json['banner_ad_id_ios'] as String?,
        (v) => v,
      ),
      _isInterstitialAdEnabled =
          (json['interstitial_ad_status'] as String?) == '1',
      interstitialAdId = _platformResolver(
        json['interstitial_ad_id_android'] as String?,
        json['interstitial_ad_id_ios'] as String?,
        (v) => v,
      ),
      _isNativeAdEnabled = (json['native_ad_status'] as String?) == '1',
      nativeAdId = _platformResolver(
        json['native_app_id_android'] as String?,
        json['native_app_id_ios'] as String?,
        (v) => v,
      ),
      storeLink = _platformResolver(
        json['play_store_link'] as String?,
        json['app_store_link'] as String?,
        (v) => v,
      ),
      defaultLatitude = json['default_latitude'] as String,
      defaultLongitude = json['default_longitude'] as String,
      minRadius = num.parse(json['min_length'] as String),
      maxRadius = num.parse(json['max_length'] as String),
      isEmailAuthEnabled = (json['email_authentication'] as String?) == '1',
      isPhoneAuthEnabled = (json['mobile_authentication'] as String?) == '1',
      isGoogleAuthEnabled = (json['google_authentication'] as String?) == '1',
      isAppleAuthEnabled = (json['apple_authentication'] as String?) == '1',
      isReferAndEarnEnabled = (json['refer_earn_enabled'] as String?) == '1',
      geminiAiEnabled = (json['gemini_ai_enabled'] as String?) == '1',
      languages = json['languages'];

  static T _platformResolver<T, V>(V android, V ios, T converter(V value)) {
    if (Platform.isAndroid) {
      return converter(android);
    } else if (Platform.isIOS) {
      return converter(ios);
    }
    throw UnimplementedError('How did you even reach here???');
  }

  final bool demoMode;
  final Version version;
  final String defaultLanguageCode;
  final String currentLanguageCode;
  final bool forceUpdate;
  final bool maintenanceMode;
  final bool isFreeAdListingEnabled;

  // TODO(I): Use enums
  final String otpProvider;
  final String mapProvider;

  final String currencySymbol;
  final String currencyIsoCode;
  final String currencyPosition;

  final bool _isBannerAdEnabled;
  final String? bannerAdId;
  final bool _isInterstitialAdEnabled;
  final String? interstitialAdId;
  final bool _isNativeAdEnabled;
  final String? nativeAdId;

  final String? storeLink;

  final String defaultLatitude;
  final String defaultLongitude;
  final num minRadius;
  final num maxRadius;

  final bool isEmailAuthEnabled;
  final bool isPhoneAuthEnabled;
  final bool isGoogleAuthEnabled;
  final bool isAppleAuthEnabled;

  final bool isReferAndEarnEnabled;
  final bool geminiAiEnabled;

  // TODO(I): Use DTO class instead of dynamic here
  final dynamic languages;

  Map get defaultLanguageMap {
    final language = (languages as List).firstWhereOrNull(
      (lang) => lang['code'] == defaultLanguageCode,
    );

    return language as Map? ?? {};
  }

  bool get isBannerAdEnabled => _isBannerAdEnabled && bannerAdId != null;

  bool get isInterstitialAdEnabled =>
      _isInterstitialAdEnabled && interstitialAdId != null;

  bool get isNativeAdEnabled => _isNativeAdEnabled && nativeAdId != null;
}
