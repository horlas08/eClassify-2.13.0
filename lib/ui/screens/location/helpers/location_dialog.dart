import 'package:eClassify/ui/screens/widgets/blurred_dialog_box.dart';
import 'package:eClassify/utils/app_icon.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:eClassify/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationDialog {
  static Future<bool?> show(
    BuildContext context, {
    required LocationPermission permission,
    required bool isLocationServiceEnabled,
  }) async {
    LoadingWidgets.hideLoader(context);

    if (permission == LocationPermission.denied) {
      _showPermissionDeniedMessage(context);
    } else if (permission == LocationPermission.deniedForever) {
      return await _showPermissionDeniedForeverDialog(context);
    } else if (!isLocationServiceEnabled) {
      return await _showLocationServiceDisabledDialog(context);
    }

    return null;
  }

  static Future<bool?> _showPermissionDeniedForeverDialog(
    BuildContext context,
  ) async {
    return await UiUtils.showBlurredDialoge(
      context,
      dialoge: BlurredDialogBox(
        svgImagePath: AppIcons.illustrators.locationDenied,
        title: 'locationPermissionDenied'.translate(context),
        content: CustomText('weNeedLocationAvailableLbl'.translate(context)),
        cancelButtonName: 'cancel'.translate(context),
        acceptButtonName: 'settingsLbl'.translate(context),
        onCancel: () async => false,
        onAccept: () async {
          Geolocator.openAppSettings();
          return true;
        },
      ),
    );
  }

  static void _showPermissionDeniedMessage(BuildContext context) {
    HelperUtils.showSnackBarMessage(
      context,
      'locationPermissionDenied'.translate(context),
    );
  }

  static Future<bool?> _showLocationServiceDisabledDialog(
    BuildContext context,
  ) async {
    return await UiUtils.showBlurredDialoge(
      context,
      dialoge: BlurredDialogBox(
        svgImagePath: AppIcons.illustrators.locationDenied,
        title: 'locationServiceDisabled'.translate(context),
        content: CustomText(
          'pleaseEnableLocationServicesManually'.translate(context),
        ),
        cancelButtonName: 'cancel'.translate(context),
        acceptButtonName: 'settingsLbl'.translate(context),
        onCancel: () async => false,
        onAccept: () async {
          Geolocator.openLocationSettings();
          return true;
        },
      ),
    );
  }
}
