import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/custom_field/fetch_custom_fields_cubit.dart';
import 'package:eClassify/data/enums.dart';
import 'package:eClassify/data/model/core/category.dart';
import 'package:eClassify/data/model/item/item_filter.dart';
import 'package:eClassify/data/model/location/leaf_location.dart';
import 'package:eClassify/ui/screens/item/item_list_screen/item_filter/budget_filter_widget.dart';
import 'package:eClassify/ui/screens/item/item_list_screen/item_filter/custom_field_filter_widget.dart';
import 'package:eClassify/ui/screens/item/item_list_screen/item_filter/filter_field.dart';
import 'package:eClassify/ui/screens/item/item_list_screen/item_filter/time_filter_bottom_sheet.dart';
import 'package:eClassify/ui/screens/widgets/dynamic_field.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/lib/extensions.dart';
import 'package:eClassify/utils/extensions/lib/translate.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({
    required this.filter,
    required this.showCategoryFilter,
    super.key,
  });

  final ItemFilter? filter;
  final bool showCategoryFilter;

  @override
  State<FilterScreen> createState() => _FilterScreenState();

  static Route route(RouteSettings routeSettings) {
    final args = routeSettings.arguments as Map<String, dynamic>?;
    return MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => FetchCustomFieldsCubit(),
        child: FilterScreen(
          filter: args?['filter'] as ItemFilter?,
          showCategoryFilter: args?['show_category_filter'] ?? true,
        ),
      ),
    );
  }
}

class _FilterScreenState extends State<FilterScreen> {
  late final ValueNotifier<LeafLocation?> _locationFilter = ValueNotifier(
    widget.filter?.location,
  );

  late final ValueNotifier<Category?> _categoryFilter = ValueNotifier(
    widget.filter?.category,
  );

  late final TextEditingController _minController = TextEditingController(
    text: widget.filter?.minPrice?.toString(),
  );
  late final TextEditingController _maxController = TextEditingController(
    text: widget.filter?.maxPrice?.toString(),
  );
  final ValueNotifier<bool> _isBudgetValid = ValueNotifier(true);

  late final ValueNotifier<PostedSince> _timeFilter = ValueNotifier(
    widget.filter?.postedSince ?? PostedSince.allTime,
  );

  late final ValueNotifier<int?> _selectedCategory = ValueNotifier(
    widget.filter?.category?.id,
  );

  late final ValueNotifier<Map<String, dynamic>?> _customFields = ValueNotifier(
    widget.filter?.customFields,
  );

  // TODO: This reset token and key-based re-mounting is a workaround because
  // dynamic fields (CustomFieldDropdown, etc.) maintain internal state that
  // isn't tied to the static AbstractField.fieldsData for reading.
  // A more robust solution would be to refactor dynamic fields to be stateless
  // or respond directly to a central state change.
  late final ValueNotifier<int> _customFieldsResetToken = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    AbstractField.fieldsData.clear();
    AbstractField.files.clear();

    // Populate AbstractField.fieldsData from existing filters to preserve them on Apply
    widget.filter?.customFields?.forEach((key, value) {
      final match = RegExp(r'custom_fields\[(\d+)\]').firstMatch(key);
      if (match != null) {
        AbstractField.fieldsData[match.group(1)!] = value;
      }
    });
  }

  @override
  void dispose() {
    _locationFilter.dispose();
    _categoryFilter.dispose();
    _minController.dispose();
    _maxController.dispose();
    _isBudgetValid.dispose();
    _timeFilter.dispose();
    _selectedCategory.dispose();
    _customFields.dispose();
    _customFieldsResetToken.dispose();
    AbstractField.fieldsData.clear();
    AbstractField.files.clear();
    super.dispose();
  }

  void _resetValues() {
    _locationFilter.value = null;
    _categoryFilter.value = widget.showCategoryFilter
        ? null
        : widget.filter?.category;
    _minController.clear();
    _maxController.clear();
    _timeFilter.value = PostedSince.allTime;
    _selectedCategory.value = widget.showCategoryFilter
        ? null
        : widget.filter?.category?.id;
    AbstractField.fieldsData.clear();
    AbstractField.files.clear();
    _customFields.value = null;
    _customFieldsResetToken.value++;
  }

  ({int? min, int? max}) _parseValues() {
    final min = int.tryParse(_minController.text.trim());
    final max = int.tryParse(_maxController.text.trim());
    return (min: min, max: max);
  }

  bool get _isRangeValid {
    final values = _parseValues();
    if (values.min == null || values.max == null) {
      return true;
    }

    return values.min! <= values.max!;
  }

  Map<String, dynamic> getCustomFields() {
    final fieldsData = AbstractField.fieldsData;
    return fieldsData.map((key, value) {
      return MapEntry('custom_fields[$key]', value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('filterTitle'.translate(context)),
        actions: [
          TextButton(
            onPressed: _resetValues,
            child: Text('reset'.translate(context)),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: Constant.appContentPadding,
          child: FilledButton(
            style: FilledButton.styleFrom(minimumSize: Size.fromHeight(48)),
            onPressed: () {
              final budget = _parseValues();
              if (!_isRangeValid) {
                HelperUtils.showSnackBarMessage(
                  context,
                  'invalidMinMaxRange'.translate(context),
                );
                return;
              }

              final customFields = getCustomFields();

              final itemFilter = ItemFilter(
                location: _locationFilter.value,
                category: _categoryFilter.value,
                minPrice: budget.min,
                maxPrice: budget.max,
                postedSince: _timeFilter.value,
                customFields: customFields,
              );

              Navigator.of(context).pop(itemFilter);
            },
            child: Text('applyFilter'.translate(context)),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: Constant.appContentPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 20,
          children: [
            ValueListenableBuilder(
              valueListenable: _locationFilter,
              builder: (context, value, child) {
                return FilterField(
                  onTap: () async {
                    final selectedLocation = await Navigator.pushNamed(
                      context,
                      Routes.locationScreen,
                    );
                    if (selectedLocation != null) {
                      _locationFilter.value = selectedLocation as LeafLocation?;
                    }
                  },
                  title: 'location'.translate(context),
                  icon: Icons.location_on,
                  value: (value?.localizedPath).isNullOrEmpty
                      ? 'global'.translate(context)
                      : value!.localizedPath,
                );
              },
            ),
            if (widget.showCategoryFilter)
              ValueListenableBuilder(
                valueListenable: _categoryFilter,
                builder: (context, value, child) {
                  return FilterField(
                    onTap: () async {
                      final selectedCategory =
                          await Navigator.pushNamed(
                                context,
                                Routes.categoryFilterScreen,
                              )
                              as Category?;
                      if (selectedCategory != null) {
                        _categoryFilter.value = selectedCategory;
                        _selectedCategory.value = selectedCategory.id;
                      }
                    },
                    title: 'category'.translate(context),
                    icon: Icons.category,
                    value: (value?.name.localized).isNullOrEmpty
                        ? 'allCategories'.translate(context)
                        : value!.name.localized,
                  );
                },
              ),
            BudgetFilterWidget(
              minController: _minController,
              maxController: _maxController,
            ),
            ValueListenableBuilder(
              valueListenable: _timeFilter,
              builder: (context, value, child) {
                return FilterField(
                  title: 'postedSince'.translate(context),
                  value: value.label.translate(context),
                  icon: Icons.date_range,
                  onTap: () async {
                    final selectedTime =
                        await showModalBottomSheet(
                              context: context,
                              builder: (context) =>
                                  const TimeFilterBottomSheet(),
                            )
                            as PostedSince?;
                    if (selectedTime != null) {
                      _timeFilter.value = selectedTime;
                    }
                  },
                );
              },
            ),
            ListenableBuilder(
              listenable: Listenable.merge([
                _customFields,
                _selectedCategory,
                _customFieldsResetToken,
              ]),
              builder: (context, child) {
                final categoryId = _selectedCategory.value;
                if (categoryId == null) return const SizedBox.shrink();
                return CustomFieldFilterWidget(
                  key: ValueKey(
                    '${categoryId}_${_customFieldsResetToken.value}',
                  ),
                  categoryId: categoryId,
                  initialData: _customFields.value,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
