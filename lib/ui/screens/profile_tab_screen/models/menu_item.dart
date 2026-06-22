import 'package:eClassify/ui/screens/profile_tab_screen/models/menu_item_action.dart';
import 'package:flutter/material.dart';

class MenuItem {
  MenuItem({
    required this.icon,
    required this.title,
    required this.action,
    this.subtitle,
    this.trailing,
    this.isDangerous = false,
  });

  final String icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final MenuItemAction action;
  final bool isDangerous;
}
