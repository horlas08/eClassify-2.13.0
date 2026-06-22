import 'package:eClassify/data/cubits/custom_field/fetch_custom_fields_cubit.dart';
import 'package:eClassify/ui/screens/item/add_item_screen/custom_filed_structure/custom_field.dart';
import 'package:eClassify/utils/extensions/lib/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomFieldFilterWidget extends StatefulWidget {
  const CustomFieldFilterWidget({
    required this.categoryId,
    this.initialData = const {},
    super.key,
  });

  final int categoryId;
  final Map<String, dynamic>? initialData;

  @override
  State<CustomFieldFilterWidget> createState() =>
      _CustomFieldFilterWidgetState();
}

class _CustomFieldFilterWidgetState extends State<CustomFieldFilterWidget> {
  late List<CustomFieldBuilder> moreDetailDynamicFields = List.empty(
    growable: true,
  );

  @override
  void initState() {
    super.initState();
    context.read<FetchCustomFieldsCubit>().fetchCustomFields(
      categoryId: widget.categoryId,
      isForFilter: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FetchCustomFieldsCubit, FetchCustomFieldState>(
      listener: (context, state) {
        if (state is FetchCustomFieldSuccess) {
          moreDetailDynamicFields = context
              .read<FetchCustomFieldsCubit>()
              .getFields()
              .where(
                (field) =>
                    field.type != "fileinput" &&
                    field.type != "textbox" &&
                    field.type != "number",
              )
              .map((field) {
                Map<String, dynamic> fieldData = field.toMap();

                if ((widget.initialData).isNotNullAndNotEmpty) {
                  final customFieldKey = 'custom_fields[${fieldData['id']}]';
                  if (widget.initialData!.containsKey(customFieldKey)) {
                    fieldData['value'] = widget.initialData![customFieldKey];
                    fieldData['isEdit'] = true;
                  }
                }

                CustomFieldBuilder customFieldBuilder = CustomFieldBuilder(
                  fieldData,
                );
                customFieldBuilder.stateUpdater(setState);
                customFieldBuilder.init();
                return customFieldBuilder;
              })
              .toList();
          setState(() {});
        }
      },
      builder: (context, state) {
        if (moreDetailDynamicFields.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: moreDetailDynamicFields.map((field) {
              field.stateUpdater(setState);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 9.0),
                child: field.build(context),
              );
            }).toList(),
          );
        } else {
          return SizedBox();
        }
      },
    );
  }
}
