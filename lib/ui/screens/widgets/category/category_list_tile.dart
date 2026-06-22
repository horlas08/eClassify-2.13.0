import 'package:eClassify/data/model/core/category.dart';
import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/ui/screens/widgets/category/category_config_scope.dart';
import 'package:flutter/material.dart';

/// Unified list tile for categories.
class CategoryListTile extends StatelessWidget {
  const CategoryListTile({
    required this.category,
    required this.onTap,
    this.isForAllCategory = false,
    super.key,
  });

  final Category category;
  final bool isForAllCategory;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = switch(isForAllCategory){
      true => '${'allIn'.translate(context)} ${category.name.localized}',
      false => category.name.localized,
    };


    return ListTile(
      onTap: onTap,
      leading: CustomImage(
        src: category.image,
        size: const Size.square(40),
        radius: 20,
        fit: BoxFit.cover,
      ),
      title: Text(label, style: context.labelLarge),
      subtitle: CategoryConfigScope.of(context)?.subtitleBuilder?.call(context, category),
      trailing: SizedBox.square(
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
