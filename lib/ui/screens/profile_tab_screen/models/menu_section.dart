import 'package:eClassify/ui/screens/profile_tab_screen/models/menu_item.dart';

class MenuSection {
  MenuSection({required this.title, required this.icon, required this.items});

  final String title;
  final String icon;
  final List<MenuItem> items;
}
