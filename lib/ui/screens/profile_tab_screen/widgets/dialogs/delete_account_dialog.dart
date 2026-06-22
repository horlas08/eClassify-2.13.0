import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/app_icon.dart';
import 'package:eClassify/utils/extensions/lib/translate.dart';
import 'package:flutter/material.dart';

class DeleteAccountDialog {
  static Future<bool?> show(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: CustomImage(src: AppIcons.illustrators.delete),
          title: Text(
            "deleteProfileMessageTitle".translate(context),
            style: context.titleLarge,
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _bulletPoint(
                context,
                "yourAdsAndTransactionDelete".translate(context),
              ),
              _bulletPoint(
                context,
                "accDetailsCanNotRecovered".translate(context),
              ),
              _bulletPoint(
                context,
                "subscriptionsCancelled".translate(context),
              ),
              _bulletPoint(
                context,
                "savedPreferencesAndMessagesLost".translate(context),
              ),
            ],
          ),
          actions: [
            Row(
              spacing: 10,
              children: [
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: context.colorScheme.surface,
                      foregroundColor: context.colorScheme.onSurface,
                    ),
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('cancel'.translate(context)),
                  ),
                ),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text('confirm'.translate(context)),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

Widget _bulletPoint(BuildContext context, String text) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 5,
    children: [
      Text('• ', style: context.bodyLarge.bold),
      Expanded(child: Text(text, style: context.bodyMedium)),
    ],
  );
}
