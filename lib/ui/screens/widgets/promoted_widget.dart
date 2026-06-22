import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:flutter/material.dart';

import 'package:eClassify/utils/extensions/extensions.dart';

class PromotedCard extends StatelessWidget {
  final Color? color;
  const PromotedCard({this.color, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 24,
      decoration: BoxDecoration(
          color: context.color.territoryColor,
          borderRadius: BorderRadius.circular(4)),
      alignment: Alignment.center,
      child: CustomText(
        "featured".translate(context),
        color: context.color.onPrimary,
        fontWeight: FontWeight.bold,
        fontSize: context.font.smaller,
      ),
    );
  }
}
