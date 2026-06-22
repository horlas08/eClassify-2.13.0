import 'dart:io';

import 'package:eClassify/ui/screens/referral/widgets/referral_steps_widget.dart';
import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/app_icon.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/extensions/lib/extensions.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});

  static Route<dynamic> route(RouteSettings settings) {
    return MaterialPageRoute<dynamic>(
      settings: settings,
      builder: (context) => const ReferralScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final referralCode = HiveUtils.getUserDetails().referralCode;
    return Scaffold(
      appBar: AppBar(title: Text('referAndEarn'.translate(context))),
      body: Padding(
        padding: Constant.appContentPadding,
        child: Card(
          elevation: 0,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 20,
              children: [
                CustomImage(src: AppIcons.illustrators.referral),
                const ReferralStepsWidget(),
                Text(
                  'referralCode'.translate(context),
                  style: context.labelLarge,
                ),
                if (referralCode.isNotNullAndNotEmpty)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.mutedColor),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(referralCode!, style: context.bodyMedium),
                          IconButton(
                            onPressed: () async {
                              final data = ClipboardData(text: referralCode);
                              await Clipboard.setData(data);
                              if (Platform.isIOS) {
                                HelperUtils.showSnackBarMessage(
                                  context,
                                  'Copied to clipboard',
                                );
                              }
                            },
                            icon: Icon(Icons.copy),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
