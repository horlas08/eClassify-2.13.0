import 'package:eClassify/data/cubits/category/main_category_cubit.dart';
import 'package:eClassify/data/cubits/chat/chat_list_cubit.dart';
import 'package:eClassify/data/cubits/chat/seller_item_offers_cubit.dart';
import 'package:eClassify/data/cubits/home/featured_section_cubit.dart';
import 'package:eClassify/data/cubits/home/home_items_cubit.dart';
import 'package:eClassify/data/cubits/location/leaf_location_cubit.dart';
import 'package:eClassify/data/cubits/report/report_reason_cubit.dart';
import 'package:eClassify/data/cubits/system/fetch_language_cubit.dart';
import 'package:eClassify/data/cubits/system/language_cubit.dart';
import 'package:eClassify/data/repositories/category/category_store.dart';
import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/app_session.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/extensions/lib/gap.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:eClassify/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LanguagesListScreen extends StatefulWidget {
  const LanguagesListScreen({super.key});

  static Route route(RouteSettings settings) {
    return MaterialPageRoute(builder: (context) => const LanguagesListScreen());
  }

  @override
  State<LanguagesListScreen> createState() => _LanguagesListScreenState();
}

class _LanguagesListScreenState extends State<LanguagesListScreen> {
  final String _currentLanguageCode = AppSession.currentLanguageCode;
  bool hasLanguageChanged = false;

  void _onBackPressed() {
    if (hasLanguageChanged &&
        _currentLanguageCode != AppSession.currentLanguageCode) {
      final location = context.read<LeafLocationCubit>().state;
      context.read<LeafLocationCubit>().refresh();
      CategoryStore.instance.clearCache(all: true);
      context.read<MainCategoryCubit>().fetch();
      // This will re-fetch the reasons from the API on the next item report
      // with the current language
      context.read<ReportReasonCubit>().clear();

      // We don't need to wait for refresh to complete to call the below apis
      // because refresh is only for translation updates and the below apis
      // expects english or default values, hence we can rely on previous state
      // without any issue.
      //
      // We only call these apis here if the location is null in which case, the refresh()
      // function above will be No-Op hence the listener in home_screen will not be triggered.
      // If we remove this check then there are multiple api calls as the home screen
      // is also listening to the change in LeafLocationCubit and calling these apis accordingly
      // hence to avoid multiple calls we wrap it with this condition.
      if (location == null) {
        context.read<FeaturedSectionCubit>().fetch(location: location);
        context.read<HomeItemsCubit>().getHomeItems(location: location);
        if (HiveUtils.isUserAuthenticated()) {
          context.read<SellerItemOffersCubit>().getOffers();
          context.read<BuyingChatListCubit>().getChatUsers();
        }
      }
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    List setting = Constant.systemSettings.languages as List? ?? [];

    var language = context.watch<LanguageCubit>().state;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _onBackPressed();
      },
      child: Scaffold(
        backgroundColor: context.color.primaryColor,
        appBar: UiUtils.buildAppBar(
          context,
          showBackButton: true,
          onBackPress: _onBackPressed,
          title: "chooseLanguage".translate(context),
        ),
        body: BlocListener<FetchLanguageCubit, FetchLanguageState>(
          listener: (context, state) {
            if (state is FetchLanguageInProgress) {
              LoadingWidgets.showLoader(context);
            }
            if (state is FetchLanguageSuccess) {
              LoadingWidgets.hideLoader(context);

              Map<String, dynamic> map = state.toMap();

              print("map language data***$map");

              var data = map['file_name'];
              map['data'] = data;
              map.remove("file_name");

              HiveUtils.storeLanguage(map);
              context.read<LanguageCubit>().changeLanguages(map);
              hasLanguageChanged = true;
            }
            if (state is FetchLanguageFailure) {
              LoadingWidgets.hideLoader(context);
            }
          },
          child: SafeArea(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: setting.length,
              padding: Constant.appContentPadding.copyWith(top: 20),
              itemBuilder: (context, index) {
                final selected =
                    (language as LanguageLoader).language['code'] ==
                    setting[index]['code'];

                final color = selected
                    ? context.color.territoryColor
                    : context.color.secondaryColor;

                return ListTile(
                  minTileHeight: 70,
                  tileColor: color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () {
                    context.read<FetchLanguageCubit>().getLanguage(
                      setting[index]['code'],
                    );
                  },
                  leading: CustomImage(
                    src: setting[index]['image'],
                    radius: 21,
                    size: Size.square(42),
                    fit: BoxFit.cover,
                  ),
                  subtitle:
                      setting[index]['name_in_english'].toString().isNotEmpty
                      ? CustomText(
                          setting[index]['name_in_english'],
                          color:
                              (language).language['code'] ==
                                  setting[index]['code']
                              ? context.color.buttonColor.withValues(alpha: 0.7)
                              : context.color.textColorDark,
                          fontSize: context.font.small,
                        )
                      : null,
                  title: CustomText(
                    setting[index]['name'],
                    color: (language).language['code'] == setting[index]['code']
                        ? context.color.buttonColor
                        : context.color.textColorDark,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
              separatorBuilder: (context, index) => 8.vGap,
            ),
          ),
        ),
      ),
    );
  }
}
