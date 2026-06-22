import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/app_icon.dart';
import 'package:eClassify/utils/extensions/lib/translate.dart';
import 'package:flutter/material.dart';

class LogoutDialog {
  static Future<bool?> show(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: CustomImage(src: AppIcons.illustrators.logout),
          title: Text(
            "confirmLogoutTitle".translate(context),
            style: context.titleLarge,
          ),
          content: Text(
            "confirmLogOutMsg".translate(context),
            style: context.titleMedium,
            textAlign: TextAlign.center,
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
