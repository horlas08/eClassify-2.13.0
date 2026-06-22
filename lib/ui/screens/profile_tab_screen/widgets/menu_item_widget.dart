import 'package:eClassify/ui/screens/profile_tab_screen/models/menu_item.dart';
import 'package:eClassify/ui/screens/profile_tab_screen/widgets/leading_icon_widget.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

class MenuItemWidget extends StatelessWidget {
  const MenuItemWidget({required this.item, super.key});
  final MenuItem item;

  @override
  Widget build(BuildContext context) {
    final color = item.isDangerous ? Colors.red : null;
    return ListTile(
      splashColor: Colors.transparent,
      onTap: () => item.action.execute(context),
      leading: LeadingIconWidget(icon: item.icon, color: color),
      title: Text(item.title),
      titleTextStyle: context.titleSmall.copyWith(color: color),
      subtitle: item.subtitle != null ? Text(item.subtitle!) : null,
      trailing:
          item.trailing ??
          SizedBox.square(
            dimension: 32,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: context.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.chevron_right),
            ),
          ),
    );
  }
}
