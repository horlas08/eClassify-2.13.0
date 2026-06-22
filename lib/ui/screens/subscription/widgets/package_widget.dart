import 'dart:math';

import 'package:eClassify/data/model/subscription/subscription_package.dart';
import 'package:eClassify/ui/screens/subscription/widgets/label_border.dart';
import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/ui/screens/widgets/hexagon_shape_border.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/app_icon.dart';
import 'package:eClassify/utils/app_session.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PackageWidget extends StatelessWidget {
  const PackageWidget({
    required this.package,
    required this.activePlanCapLabel,
    this.isSelected = false,
    super.key,
  });

  final SubscriptionPackage package;
  final bool isSelected;
  final String activePlanCapLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: package.isActive ? EdgeInsets.only(top: 20) : EdgeInsets.zero,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: package.isPurchasable || package.isActive
              ? context.colorScheme.secondary
              : context.colorScheme.onSurface.withValues(alpha: .05),
          borderRadius: BorderRadius.circular(12),
          border: switch ((package.isActive, isSelected)) {
            (true, _) => LabeledBorder(
              label: activePlanCapLabel,
              textStyle: context.labelMedium.copyWith(
                color: context.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
              color: context.colorScheme.primary,
            ),
            (false, true) => Border.all(color: context.colorScheme.primary),
            (_, _) => null,
          },
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            spacing: 10,
            children: [
              Row(
                spacing: 10,
                children: [
                  DecoratedBox(
                    decoration: ShapeDecoration(
                      color: ThemeColors.borderColor,
                      shape: HexagonBorderShape(cornerRadius: 5),
                    ),
                    child: SizedBox.square(
                      dimension: 45,
                      child: Center(
                        child: CustomImage(
                          src: package.icon,
                          size: Size.square(20),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      package.name.localized,
                      maxLines: 3,
                      style: context.titleMedium.bold,
                    ),
                  ),
                  if (!package.isActive)
                    Radio<SubscriptionPackage>(value: package),
                ],
              ),
              if (package.isActive)
                ActivePackageWidget(package: package.activePackages.first)
              else ...[
                const Divider(color: ThemeColors.borderColor),
                InactivePackageWidget(package: package),
              ],
              if (package.keyPoints.isNotEmpty) ...[
                const Divider(color: ThemeColors.borderColor),
                AnimatedList(
                  points: package.keyPoints,
                  title: 'featuresList'.translate(context),
                ),
              ],
              if (package.categories.isNotEmpty)
                AnimatedList(
                  points: package.categories,
                  title: 'categoriesIncluded'.translate(context),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedList extends StatefulWidget {
  const AnimatedList({required this.points, required this.title, super.key});
  final List<String> points;
  final String title;

  @override
  State<AnimatedList> createState() => _AnimatedListState();
}

class _AnimatedListState extends State<AnimatedList> {
  final ValueNotifier<bool> _showMore = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _showMore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        Text(
          widget.title,
          style: context.labelMedium.withColor(context.mutedColor),
        ),
        AnimatedSize(
          alignment: Alignment.topCenter,
          duration: const Duration(milliseconds: 300),
          child: ValueListenableBuilder(
            valueListenable: _showMore,
            builder: (context, value, child) {
              final totalKeyPoints = widget.points.length;
              final totalKeyPointsToShow = value
                  ? totalKeyPoints
                  : min(3, totalKeyPoints);
              final shouldShowViewMore = totalKeyPoints > totalKeyPointsToShow;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List.generate(totalKeyPointsToShow, (index) {
                  return RichText(
                    textAlign: TextAlign.left,
                    text: TextSpan(
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: CustomImage(
                            src: AppIcons.common.activeMark,
                            size: Size.square(16),
                          ),
                        ),
                        const TextSpan(text: '\t\t'),
                        TextSpan(
                          text: widget.points[index],
                          style: context.labelLarge,
                        ),
                        if (index == totalKeyPointsToShow - 1 &&
                            (shouldShowViewMore || value)) ...[
                          const TextSpan(text: '\t'),
                          TextSpan(
                            text: value
                                ? 'viewLess'.translate(context)
                                : 'viewMore'.translate(context),
                            style: context.labelLarge.copyWith(
                              color: context.colorScheme.primary,
                              decoration: TextDecoration.underline,
                              decorationColor: context.colorScheme.primary,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                _showMore.value = !_showMore.value;
                              },
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ],
    );
  }
}

class InactivePackageWidget extends StatelessWidget {
  const InactivePackageWidget({required this.package, super.key});

  final SubscriptionPackage package;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          spacing: 10,
          children: [
            Text(
              '${package.itemLimit.translate(context)} ${'ads'.translate(context)}',
              style: context.labelLarge.bold,
            ),
            const Spacer(),
            if (package.discount != 0)
              DecoratedBox(
                decoration: BoxDecoration(
                  color: context.colorScheme.primary.withValues(alpha: .2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  child: Text(
                    '${package.discount}% ${'off'.translate(context).toUpperCase()}',
                    style: context.labelMedium.withColor(
                      context.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            Text(
              '${package.isFree ? 'free'.translate(context) : package.formattedDiscountedPrice}',
              style: context.labelLarge.bold.withColor(
                context.colorScheme.primary,
              ),
            ),
          ],
        ),
        Row(
          spacing: 10,
          children: [
            Text(
              '${package.listingDurationDays} ${'days'.translate(context)}',
              style: context.labelLarge.bold.withColor(context.mutedColor),
            ),
            const Spacer(),
            if (package.discount != 0)
              Text(
                '${package.formattedPrice}',
                style: context.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.mutedColor,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: context.mutedColor,
                  decorationThickness: 2,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class ActivePackageWidget extends StatelessWidget {
  const ActivePackageWidget({required this.package, super.key});

  final ActivePackage package;

  Widget _keyValueWidget(BuildContext context, String key, String value) {
    return Column(
      children: [
        Text(key, style: context.bodySmall.copyWith(color: context.mutedColor)),
        Text(value, style: context.labelMedium),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasUnlimitedLimit = package.itemLimit == null;
    final percentageUsed = hasUnlimitedLimit
        ? 1.0
        : 1.0 - package.remainingItemLimit! / package.itemLimit!;
    final hasUnlimitedDuration = package.end == null;
    return Column(
      spacing: 10,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('adsUsage'.translate(context), style: context.labelMedium),
            Text(
              '${hasUnlimitedLimit ? 'unlimited'.translate(context) : '${package.usedLimit}/${package.itemLimit}'}',
              style: context.labelMedium,
            ),
          ],
        ),
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: percentageUsed),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.decelerate,
          builder: (context, value, child) {
            return LinearProgressIndicator(
              value: value,
              borderRadius: BorderRadius.circular(16),
              backgroundColor: context.colorScheme.primary.withValues(
                alpha: .2,
              ),
              minHeight: 8,
            );
          },
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _keyValueWidget(
                  context,
                  'started'.translate(context),
                  DateFormat(
                    'dd MMM yyyy',
                    AppSession.currentLocale,
                  ).format(package.start),
                ),
                const SizedBox(
                  height: 10,
                  child: VerticalDivider(color: ThemeColors.borderColor),
                ),
                _keyValueWidget(
                  context,
                  'expires'.translate(context),
                  hasUnlimitedDuration
                      ? '-'
                      : DateFormat(
                          'dd MMM yyyy',
                          AppSession.currentLocale,
                        ).format(package.end!),
                ),
                const SizedBox(
                  height: 10,
                  child: VerticalDivider(color: ThemeColors.borderColor),
                ),
                _keyValueWidget(
                  context,
                  'remaining'.translate(context),
                  hasUnlimitedDuration
                      ? 'unlimited'.translate(context)
                      : '${package.end!.difference(package.start).inDays} ${'days'.translate(context)}',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
