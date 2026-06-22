import 'dart:math';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:eClassify/app_config.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/utils/app_session.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/touch_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

enum MessageType {
  success(StatusColors.successMessageColor),
  warning(StatusColors.warningMessageColor),
  error(StatusColors.errorMessageColor);

  final Color value;

  const MessageType(this.value);
}

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
}

class HelperUtils {
  static String shareUrl(String type, String value) {
    return "${AppConfig.shareDomain}/${AppSession.currentLanguageCode.toLowerCase()}/$type/$value";
  }

  static void shareItem(BuildContext context, String type, String slug) {
    final TapGuard _guard = TapGuard();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.copy),
                title: CustomText("copylink".translate(context)),
                onTap: () async {
                  String deepLink = shareUrl(type, slug);

                  await Clipboard.setData(ClipboardData(text: deepLink));

                  Navigator.pop(context);
                  HelperUtils.showSnackBarMessage(
                    context,
                    "copied".translate(context),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: CustomText("share".translate(context)),
                onTap: () async {
                  String deepLink = shareUrl(type, slug);
                  final box = context.findRenderObject() as RenderBox?;
                  String text =
                      "${"shareDetailsMsg".translate(context)}:\n$deepLink.";
                  _guard.run(() async {
                    await SharePlus.instance.share(
                      ShareParams(
                        text: text,
                        sharePositionOrigin:
                            box!.localToGlobal(Offset.zero) & box.size,
                      ),
                    );
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static void unfocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  static dynamic showSnackBarMessage(
    BuildContext context,
    String message, {
    int messageDuration = 3,
    MessageType? type,
    bool isFloating = true,
    VoidCallback? onClose,
    SnackBarAction? snackBarAction,
  }) async {
    var snackBar = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: CustomText(message, color: context.color.secondaryColor),
        behavior: (isFloating) ? SnackBarBehavior.floating : null,
        backgroundColor: type?.value ?? context.color.inverseThemeColor,
        duration: Duration(seconds: messageDuration),
        action: snackBarAction,
      ),
    );
    var snackBarClosedReason = await snackBar.closed;
    if (SnackBarClosedReason.values.contains(snackBarClosedReason)) {
      onClose?.call();
    }
  }

  static String getFileSizeString({required int bytes, int decimals = 0}) {
    const suffixes = ["b", "kb", "mb", "gb", "tb"];
    if (bytes == 0) return '0${suffixes[0]}';
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + suffixes[i];
  }

  static void killPreviousPages(BuildContext context, var nextpage, var args) {
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(nextpage, (route) => false, arguments: args);
  }

  static void goToNextPage(
    var nextpage,
    BuildContext bcontext,
    bool isreplace, {
    Map? args,
  }) {
    if (isreplace) {
      Navigator.of(bcontext).pushReplacementNamed(nextpage, arguments: args);
    } else {
      Navigator.of(bcontext).pushNamed(nextpage, arguments: args);
    }
  }

  static Widget checkVideoType(
    String url, {
    required Widget Function() onYoutubeVideo,
    required Widget Function() onOtherVideo,
  }) {
    if (isYoutubeVideo(url)) {
      return onYoutubeVideo.call();
    } else {
      return onOtherVideo.call();
    }
  }

  static bool isYoutubeVideo(String url) {
    List youtubeDomains = ["youtu.be", "youtube.com"];

    Uri uri = Uri.parse(url);
    var host = uri.host.toString().replaceAll("www.", "");

    return youtubeDomains.contains(host);
  }

  static void launchPathURL({
    required bool isTelephone,
    required bool isSMS,
    required bool isMail,
    required String value,
    required BuildContext context,
  }) async {
    late Uri redirectUri;

    if (isTelephone) {
      redirectUri = Uri.parse("tel:$value");
    } else if (isMail) {
      redirectUri = Uri(
        scheme: 'mailto',
        path: value,
        query:
            'subject=${AppConfig.applicationName}&body=${"mailMsgLbl".translate(context)}',
      );
    } else {
      redirectUri = Uri.parse("sms:$value");
    }

    if (await canLaunchUrl(redirectUri)) {
      await launchUrl(redirectUri);
    } else {
      throw 'Could not launch $redirectUri';
    }
  }

  static double lerpHeight({
    required double screenHeight,
    required double minHeight,
    required double maxHeight,
    required double minScreen,
    required double maxScreen,
  }) {
    // Normalize screen height to 0–1
    final t = ((screenHeight - minScreen) / (maxScreen - minScreen)).clamp(
      0.0,
      1.0,
    );

    // Lerp between min/max height
    return lerpDouble(minHeight, maxHeight, t)!;
  }

  static String getFormattedNumber(
    String mobile,
    String? phoneCode,
    String? regionCode,
  ) {
    String? pCode = phoneCode;
    String? rCode = regionCode;

    // Case 1: Both null, use defaults
    if (pCode == null && rCode == null) {
      pCode = AppConfig.defaultPhoneCode;
      rCode = AppConfig.defaultCountryCode;
    }

    // Case 2: regionCode is present (either originally or via default)
    if (rCode != null) {
      final countries = CountryManager().countries;
      final country = countries.firstWhereOrNull(
        (element) => element.countryCode.toUpperCase() == rCode!.toUpperCase(),
      );

      if (country != null) {
        try {
          final formatted = formatNumberSync(
            mobile,
            country: country,
            inputContainsCountryCode: false,
          );
          return normalizeNumber('${country.phoneCode} $formatted');
        } catch (e) {
          // Fallback if formatting fails
          return normalizeNumber('${pCode ?? country.phoneCode} $mobile');
        }
      }
    }

    // Case 3: regionCode is null (or not found) but phoneCode is available
    if (pCode != null) {
      return normalizeNumber('$pCode $mobile');
    }

    // Final fallback
    return normalizeNumber(mobile);
  }

  static String normalizeNumber(String mobile) {
    mobile = mobile.replaceFirst(RegExp(r'^\++'), '+'); // collapse multiple +
    if (!mobile.startsWith('+')) {
      mobile = '+$mobile';
    }
    return mobile;
  }

  static String formattedSalaryRange(String minimum, String maximum) {
    final min = num.tryParse(minimum);
    final max = num.tryParse(maximum);
    if (min == null && max == null) {
      return '';
    } else if (min == null) {
      return 'Up to $maximum';
    } else if (max == null) {
      return 'From $minimum';
    } else {
      return '$minimum - $maximum';
    }
  }
}
