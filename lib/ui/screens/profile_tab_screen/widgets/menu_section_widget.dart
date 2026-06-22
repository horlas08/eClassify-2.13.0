import 'package:eClassify/ui/screens/profile_tab_screen/models/menu_section.dart';
import 'package:eClassify/ui/screens/profile_tab_screen/widgets/leading_icon_widget.dart';
import 'package:eClassify/ui/screens/profile_tab_screen/widgets/menu_item_widget.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:flutter/material.dart';

class MenuSectionWidget extends StatelessWidget {
  const MenuSectionWidget({required this.section, super.key});

  final MenuSection section;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      backgroundColor: context.colorScheme.backgroundColor,
      collapsedBackgroundColor: context.colorScheme.backgroundColor,
      textColor: context.colorScheme.primary,
      shape: LinearBorder.none,
      collapsedShape: LinearBorder.none,
      expansionAnimationStyle: AnimationStyle(
        curve: Curves.easeOutCubic,
        duration: const Duration(milliseconds: 500,),
        reverseDuration: const Duration(milliseconds: 500
        ),
        reverseCurve: Curves.easeInCubic
      ),
      splashColor: Colors.transparent,
      title: Text(section.title),
      leading: LeadingIconWidget(icon: section.icon),
      children: section.items
          .map((item) => MenuItemWidget(item: item))
          .toList(),
    );
  }
}
