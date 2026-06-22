import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/extensions/lib/gap.dart';
import 'package:flutter/material.dart';

class ReferralStepsWidget extends StatelessWidget {
  const ReferralStepsWidget({super.key});

  static const _steps = [
    'referralStepOne',
    'referralStepTwo',
    'referralStepThree',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('howItWorks'.translate(context), style: context.titleSmall),
        10.vGap,
        Column(
          spacing: 20,
          children: [
            ..._steps.indexed.map((step) {
              final stepNumber = (step.$1 + 1).toString().padLeft(2, '0');
              return Row(
                spacing: 10,
                children: [
                  CircleAvatar(
                    backgroundColor: context.colorScheme.primary,
                    radius: 12,
                    child: Text(
                      stepNumber,
                      style: context.labelSmall.withColor(
                        context.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      step.$2.translate(context),
                      style: context.labelLarge,
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }
}
