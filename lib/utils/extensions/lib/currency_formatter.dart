import 'package:eClassify/data/model/currency.dart';
import 'package:eClassify/utils/app_session.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:intl/intl.dart';

extension NumberFormatter on double {
  String currencyFormat([Currency? currency]) {
    final formatted = this.decimalFormat;

    if(currency != null) {
      return NumberFormat.currency(
        name: currency.code,
        symbol: currency.symbol,
      ).format(this);
    }

    return Constant.systemSettings.currencyPosition == 'left'
        ? '${Constant.systemSettings.currencySymbol} $formatted'
        : '$formatted ${Constant.systemSettings.currencySymbol}';
  }

  String get decimalFormat {
    final supportsLocale = NumberFormat.localeExists(AppSession.currentLocale);
    final numberFormat = NumberFormat.decimalPatternDigits(
      locale: supportsLocale ? AppSession.currentLocale : Intl.defaultLocale,
      decimalDigits: 2,
    );
    return numberFormat.format(this);
  }
}
