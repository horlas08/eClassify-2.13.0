import 'package:eClassify/data/model/localized_string.dart';
import 'package:eClassify/data/model/location/leaf_location.dart';

class AppConfig {
  /// Used in SplashScreen to display application name under splash logo
  static const String applicationName = 'Bazinjan';

  /// Default SEO meta tags for the platform
  static const String metaTitle =
      'Bazinjan Platform | Your Ultimate Guide to Buying and Selling Anything in Sudan';

  static const String metaDescription =
      'Your ultimate guide to buying and selling in Sudan. Post your ad for free or browse thousands of listings on Bazinjan Marketplace today.';

  static const String metaKeywords =
      'Bazinjan Sudan, Sudan open market, Sudan classifieds, Sudan marketplace, buy and sell Sudan, free ads Sudan, Khartoum open market, Sudan online shopping, cars for sale Sudan, used cars Khartoum, Sudan auto market, real estate Sudan, apartments for rent Khartoum, houses for sale Sudan, lands for sale Khartoum, mobile phones Sudan, used phones Khartoum, laptops Sudan, iPhone prices Sudan, jobs in Sudan, Sudan services, furniture Sudan, Bazinjan marketplace, Sudan free classifieds, online market Sudan, buy cars Sudan, Khartoum property, Sudan electronics, advertising Sudan.';

  /// DO NOT ADD "/" AT THE END OF DOMAINS ///
  /// Admin Panel URL
  static const String hostUrl = 'https://admin.bazinjan.com';

  /// Website URL to generate share links
  static const String shareDomain = "https://admin.bazinjan.com";

  /// Default location to be used when App is unable to fetch current location
  static final LeafLocation defaultLocation = LeafLocation(
    country: LocalizedString(canonical: 'Sudan'),
    state: LocalizedString(canonical: 'Khartoum'),
    city: LocalizedString(canonical: 'Khartoum'),
  );

  /// Default latitude and longitude to show on the Google Map when
  /// the user hasn’t selected a location.
  ///
  /// Setting these values to 0.0 makes them dynamic, in which case
  /// the defaults from the Admin Panel will be used.
  static double defaultLatitude = 15.5007;
  static double defaultLongitude = 32.5599;

  /// 2-Digit ISO code of Country
  /// Refer to countrycode.org to find out country's 2-Digit ISO code
  static const String defaultCountryCode = 'SD';

  /// Calling code of country
  /// DO NOT USE + SIGN IN FRONT OF CODE
  static const String defaultPhoneCode = '249';

  /// Show the company logo at the bottom of splash screen
  /// To change the logo, replace assets/icons/branding/company_logo.jpeg
  /// SVG format is recommended here.
  /// To use any other formats, provide full asset URL in splash_screen.dart
  static const bool showCompanyLogo = true;
}
