import 'package:eClassify/app/routes.dart';
import 'package:eClassify/app_config.dart';
import 'package:eClassify/data/cubits/auth/authentication_cubit.dart';
import 'package:eClassify/data/cubits/auth/login_cubit.dart';
import 'package:eClassify/data/cubits/auth/user_profile_cubit.dart';
import 'package:eClassify/data/cubits/followers/follow_user_list_cubit.dart';
import 'package:eClassify/data/cubits/seller/fetch_verification_request_cubit.dart';
import 'package:eClassify/data/cubits/subscription/active_subscription_package_cubit.dart';
import 'package:eClassify/data/cubits/system/app_theme_cubit.dart';
import 'package:eClassify/ui/screens/profile_tab_screen/models/menu_item.dart';
import 'package:eClassify/ui/screens/profile_tab_screen/models/menu_item_action.dart';
import 'package:eClassify/ui/screens/profile_tab_screen/widgets/dialogs/delete_account_dialog.dart';
import 'package:eClassify/ui/screens/profile_tab_screen/widgets/dialogs/logout_dialog.dart';
import 'package:eClassify/ui/screens/profile_tab_screen/widgets/menu_item_widget.dart';
import 'package:eClassify/ui/screens/profile_tab_screen/widgets/profile_header.dart';
import 'package:eClassify/ui/screens/profile_tab_screen/widgets/profile_listeners_scope.dart';
import 'package:eClassify/ui/screens/profile_tab_screen/widgets/referral_points_tile.dart';
import 'package:eClassify/ui/screens/profile_tab_screen/widgets/user_verification_card.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/app_icon.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileTabScreen extends StatefulWidget {
  const ProfileTabScreen({super.key});

  @override
  State<ProfileTabScreen> createState() => _ProfileTabScreenState();
}

class _ProfileTabScreenState extends State<ProfileTabScreen>
    with AutomaticKeepAliveClientMixin<ProfileTabScreen> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isAuthenticated = HiveUtils.isUserAuthenticated();
    final showLanguageMenu =
        ((Constant.systemSettings.languages as List?)?.length ?? 0) > 1;

    final menuItems = [
      if (isAuthenticated)
        MenuItem(
          icon: AppIcons.profile.featuredAds,
          title: 'myFeaturedAds'.translate(context),
          action: ScreenPushAction(route: Routes.myAdvertisment),
        ),
      MenuItem(
        icon: AppIcons.profile.subscription,
        title: 'subscription'.translate(context),
        action: CustomAction(
          onTap: () async {
            if (isAuthenticated) {
              context.read<ActiveSubscriptionPackageCubit>().getPackages();
            } else {
              Navigator.pushNamed(context, Routes.subscriptionScreen);
            }
          },
        ),
      ),
      if (isAuthenticated && Constant.systemSettings.isReferAndEarnEnabled)
        MenuItem(
          icon: AppIcons.profile.referral,
          title: 'referAndEarn'.translate(context),
          action: ScreenPushAction(route: Routes.referralScreen),
        ),
      if (isAuthenticated)
        MenuItem(
          icon: AppIcons.profile.transactionHistory,
          title: 'transactionHistory'.translate(context),
          action: ScreenPushAction(route: Routes.transactionHistory),
        ),
      if (isAuthenticated)
        MenuItem(
          icon: AppIcons.profile.myReview,
          title: 'myReview'.translate(context),
          action: ScreenPushAction(route: Routes.myReviewsScreen),
        ),
      if (isAuthenticated)
        MenuItem(
          icon: AppIcons.profile.myJobApplication,
          title: 'myJobApplications'.translate(context),
          action: ScreenPushAction(
            route: Routes.jobApplicationList,
            args: {'itemId': 0, 'isMyJobApplications': true},
          ),
        ),
      if (showLanguageMenu)
        MenuItem(
          icon: AppIcons.profile.language,
          title: 'language'.translate(context),
          action: ScreenPushAction(route: Routes.languageListScreenRoute),
        ),
      MenuItem(
        icon: AppIcons.profile.darkTheme,
        title: 'darkTheme'.translate(context),
        action: CustomAction(
          onTap: () async {
            context.read<AppThemeCubit>().toggleTheme();
          },
        ),
        trailing: BlocBuilder<AppThemeCubit, ThemeMode>(
          builder: (context, theme) {
            return Switch(
              trackOutlineColor: WidgetStatePropertyAll(Colors.transparent),
              activeTrackColor: context.color.territoryColor,
              inactiveTrackColor: context.color.backgroundColor,
              value: theme == ThemeMode.dark,
              onChanged: (value) {
                context.read<AppThemeCubit>().toggleTheme();
              },
            );
          },
        ),
      ),

      MenuItem(
        icon: AppIcons.profile.notification,
        title: 'notifications'.translate(context),
        action: ScreenPushAction(route: Routes.notificationPage),
      ),

      MenuItem(
        icon: AppIcons.profile.blog,
        title: 'blogs'.translate(context),
        action: ScreenPushAction(route: Routes.blogsScreenRoute),
      ),
      if (isAuthenticated)
        MenuItem(
          icon: AppIcons.profile.favorites,
          title: 'favorites'.translate(context),
          action: ScreenPushAction(route: Routes.favoritesScreen),
        ),
      MenuItem(
        icon: AppIcons.profile.faqs,
        title: 'faqsLbl'.translate(context),
        action: ScreenPushAction(route: Routes.faqsScreen),
      ),
      MenuItem(
        icon: AppIcons.profile.shareApp,
        title: 'shareApp'.translate(context),
        action: CustomAction(
          onTap: () async {
            await shareApp(context);
          },
        ),
      ),
      MenuItem(
        icon: AppIcons.profile.rateUs,
        title: 'rateUs'.translate(context),
        action: CustomAction(onTap: () async => rateUs()),
      ),
      MenuItem(
        icon: AppIcons.profile.contactUs,
        title: 'contactUs'.translate(context),
        action: ScreenPushAction(route: Routes.contactUs),
      ),
      MenuItem(
        icon: AppIcons.profile.aboutUs,
        title: 'aboutUs'.translate(context),
        action: ScreenPushAction(
          route: Routes.profileSettings,
          args: {'title': "aboutUs".translate(context), 'param': Api.aboutUs},
        ),
      ),
      MenuItem(
        icon: AppIcons.profile.terms,
        title: 'termsConditions'.translate(context),
        action: ScreenPushAction(
          route: Routes.profileSettings,
          args: {
            'title': "termsConditions".translate(context),
            'param': Api.termsAndConditions,
          },
        ),
      ),
      MenuItem(
        icon: AppIcons.profile.privacy,
        title: 'privacyPolicy'.translate(context),
        action: ScreenPushAction(
          route: Routes.profileSettings,
          args: {
            'title': "privacyPolicy".translate(context),
            'param': Api.privacyPolicy,
          },
        ),
      ),
      MenuItem(
        icon: AppIcons.profile.refundPolicy,
        title: 'refundPolicy'.translate(context),
        action: ScreenPushAction(
          route: Routes.profileSettings,
          args: {
            'title': "refundPolicy".translate(context),
            'param': Api.refundPolicy,
          },
        ),
      ),
      if (isAuthenticated)
        MenuItem(
          icon: AppIcons.profile.delete,
          title: 'deleteAccount'.translate(context),
          isDangerous: true,
          action: CustomAction(
            onTap: () async {
              if (Constant.isDemoModeOn) {
                HelperUtils.showSnackBarMessage(
                  context,
                  'thisActionNotValidDemo'.translate(context),
                );
              } else {
                final shouldDelete =
                    await DeleteAccountDialog.show(context) ?? false;
                if (shouldDelete) {
                  context.read<AuthenticationCubit>().deleteUser();
                }
              }
            },
          ),
        ),
      if (Constant.isUpdateAvailable)
        MenuItem(
          icon: AppIcons.profile.update,
          title: 'update'.translate(context),
          subtitle: 'v${Constant.newVersionNumber}',
          action: CustomAction(
            onTap: () async {
              final appUrl = Constant.systemSettings.storeLink;
              final uri = Uri.tryParse(appUrl ?? '');
              if (uri != null && await canLaunchUrl(uri)) {
                launchUrl(uri);
              }
            },
          ),
        ),
    ];

    return ProfileListenersScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text('myProfile'.translate(context)),
          automaticallyImplyLeading: false,
          actions: [
            if (isAuthenticated)
              IconButton(
                onPressed: () async {
                  final shouldLogout =
                      await LogoutDialog.show(context) ?? false;
                  if (shouldLogout) {
                    context.read<LoginCubit>().logoutUser();
                  }
                },
                icon: Icon(Icons.logout_rounded),
              ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            if (!isAuthenticated) return;
            context.read<VerificationRequestCubit>().fetchVerificationRequest();
            context.read<UserProfileCubit>().getUserProfile();
            context.read<FollowingListCubit>().getUsers();
            context.read<FollowersListCubit>().getUsers();
          },
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: Constant.appContentPadding.copyWith(
              bottom: kBottomNavigationBarHeight,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 20,
              children: [
                ProfileHeader(),
                if (isAuthenticated) UserVerificationCard(),
                if (Constant.systemSettings.isReferAndEarnEnabled)
                  ReferralPointsTile(
                    onTap: () {
                      Navigator.of(
                        context,
                      ).pushNamed(Routes.referralHistoryScreen);
                    },
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
                  ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: List.generate(
                      menuItems.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 5.0),
                        child: MenuItemWidget(item: menuItems[index]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> shareApp(BuildContext context) async {
    final appUrl = Constant.systemSettings.storeLink;
    final sharePosition = Rect.fromLTWH(
      0,
      0,
      context.screenWidth,
      context.screenHeight / 2,
    );
    await SharePlus.instance.share(
      ShareParams(
        text:
            '${AppConfig.applicationName}\n$appUrl\n${"shareApp".translate(context)}',
        sharePositionOrigin: sharePosition,
      ),
    );
  }

  Future<void> rateUs() {
    final appStoreId = Constant.systemSettings.storeLink?.split('/').lastOrNull;
    return InAppReview.instance.openStoreListing(appStoreId: appStoreId);
  }
}
