import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/model/core/category.dart';
import 'package:eClassify/data/model/subscription/subscription_package.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/utils/extensions/lib/translate.dart';
import 'package:flutter/material.dart';

class NoPackageAvailableDialog {
  static void show(
    BuildContext context, {
    required SubscriptionPackageType type,
    Category? category,
  }) {
    final contentText = switch ((type, category)) {
      (SubscriptionPackageType.featuredAds, _) =>
        'featureAdSubscriptionNotice'.translate(context),
      (SubscriptionPackageType.itemListing, final Category c) =>
        'categoryItemListingSubscriptionNotice'.translate(context, {
          'category_name': c.name.localized,
        }),
      (SubscriptionPackageType.itemListing, _) =>
        'itemListingSubscriptionNotice'.translate(context),
    };

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'subscriptionRequired'.translate(context),
            style: context.titleMedium,
            textAlign: TextAlign.center,
          ),
          content: Text(
            contentText.translate(context),
            textAlign: TextAlign.center,
            style: context.bodyMedium,
          ),
          actionsPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
                    onPressed: Navigator.of(context).pop,
                    child: Text('cancel'.translate(context)),
                  ),
                ),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      final routeConfig = switch ((type, category)) {
                        (SubscriptionPackageType.featuredAds, _) => (
                          route: Routes.subscriptionPackageScreen,
                          args: null,
                        ),
                        (
                          SubscriptionPackageType.itemListing,
                          final Category c,
                        ) =>
                          (route: Routes.subscriptionPackageScreen, args: c),
                        (SubscriptionPackageType.itemListing, _) => (
                          route: Routes.subscriptionCategorySelectionScreen,
                          args: null,
                        ),
                      };
                      Navigator.of(context).popAndPushNamed(
                        routeConfig.route,
                        arguments: routeConfig.args,
                      );
                    },
                    child: Text('subscribe'.translate(context)),
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
