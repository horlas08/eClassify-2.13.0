import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/category/category_browsing_cubit.dart';
import 'package:eClassify/data/cubits/category/category_validation_cubit.dart';
import 'package:eClassify/data/model/core/category.dart';
import 'package:eClassify/data/model/subscription/subscription_package.dart';
import 'package:eClassify/ui/screens/widgets/category/category_picker.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/dialogs/no_package_available_dialog.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ListingCategorySelectionScreen extends StatelessWidget {
  const ListingCategorySelectionScreen({super.key});

  static Route<dynamic> route(RouteSettings routeSettings) {
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => BlocProvider(
        create: (_) => CategoryBrowsingCubit(),
        child: const ListingCategorySelectionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('adListing'.translate(context))),
      body: BlocListener<CategoryValidationCubit, CategoryValidationState>(
        listener: (context, state) async{
          if (state is CategoryValidationInProgress) {
            LoadingWidgets.showLoader(context);
          }
          if (state is CategoryValidationRestricted) {
            LoadingWidgets.hideLoader(context);
            NoPackageAvailableDialog.show(
              context,
              type: SubscriptionPackageType.itemListing,
              category: state.category
            );
          }
          if (state is CategoryValidationSuccess) {
            LoadingWidgets.hideLoader(context);
            final hierarchy = context
                .read<CategoryBrowsingCubit>()
                .pathNotifier
                .value;
            final result = await Navigator.pushNamed(
              context,
              Routes.addItemDetails,
              arguments: {
                'category_tree': [...hierarchy, state.category],
              },
            );

            if(result is Category){
              context.read<CategoryBrowsingCubit>().navigateBackTo(result);
            } else if(result case final int i when i == -1){
              context.read<CategoryBrowsingCubit>().navigateBackTo(null);
            }
          }
        },
        child: Padding(
          padding: Constant.appContentPadding,
          child: CategoryPicker(
            showAllOption: false,
            showBreadcrumbs: true,
            onSelect: (category, hierarchy) {
              context.read<CategoryValidationCubit>().validate(category);
            },
          ),
        ),
      ),
    );
  }
}
