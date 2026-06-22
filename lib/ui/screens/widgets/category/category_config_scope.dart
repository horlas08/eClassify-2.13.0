import 'package:eClassify/data/model/core/category.dart';
import 'package:flutter/widgets.dart';

typedef CategorySubtitleBuilder = Widget Function(BuildContext context, Category category);

class CategoryConfigScope extends InheritedWidget {
  const CategoryConfigScope({
    super.key,
    this.subtitleBuilder,
    required super.child,
  });

  final CategorySubtitleBuilder? subtitleBuilder;

  static CategoryConfigScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CategoryConfigScope>();
  }

  @override
  bool updateShouldNotify(CategoryConfigScope oldWidget) {
    return subtitleBuilder != oldWidget.subtitleBuilder;
  }
}
