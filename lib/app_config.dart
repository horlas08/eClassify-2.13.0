import 'package:eClassify/data/model/localized_string.dart';
import 'package:eClassify/data/model/location/leaf_location.dart';

class AppConfig {
  /// Used in SplashScreen to display application name under splash logo
  static const String applicationName = 'muqrns';

  /// DO NOT ADD "/" AT THE END OF DOMAINS ///
  /// Admin Panel URL
  static const String hostUrl = 'https://admin.muqrn.com';

  /// Website URL to generate share links
  static const String shareDomain = "https://admin.muqrn.com";

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
