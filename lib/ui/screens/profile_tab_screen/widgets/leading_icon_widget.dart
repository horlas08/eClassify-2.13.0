import 'package:eClassify/ui/screens/widgets/bottom_navigation_bar/svg_color_mapper.dart';
import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:flutter/material.dart';

class LeadingIconWidget extends StatelessWidget {
  const LeadingIconWidget({required this.icon, this.color, super.key});
  final String icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 32,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: (color ?? context.colorScheme.primary).withValues(alpha: .2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: CustomImage(
            src: icon,
            size: Size.square(20),
            svgColorMapper: SvgColorMapper(color: color),
          ),
        ),
      ),
    );
  }
}
