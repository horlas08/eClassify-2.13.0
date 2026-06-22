import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/auth/authentication_cubit.dart';
import 'package:eClassify/data/cubits/auth/delete_user_cubit.dart';
import 'package:eClassify/data/cubits/auth/login_cubit.dart';
import 'package:eClassify/data/cubits/chat/chat_list_cubit.dart';
import 'package:eClassify/data/cubits/chat/seller_item_offers_cubit.dart';
import 'package:eClassify/data/cubits/favorite/favorite_cubit.dart';
import 'package:eClassify/data/cubits/item/job_application/fetch_job_application_cubit.dart';
import 'package:eClassify/data/cubits/location/leaf_location_cubit.dart';
import 'package:eClassify/data/cubits/report/item_report_list_cubit.dart';
import 'package:eClassify/data/cubits/subscription/active_subscription_package_cubit.dart';
import 'package:eClassify/data/cubits/system/bottom_nav_cubit.dart';
import 'package:eClassify/data/cubits/system/user_details.dart';
import 'package:eClassify/utils/app_session.dart';
import 'package:eClassify/utils/extensions/lib/translate.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileListenersScope extends StatelessWidget {
  const ProfileListenersScope({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<DeleteUserCubit, DeleteUserState>(
          listener: (context, state) {
            if (state is DeleteUserInProgress) {
              LoadingWidgets.showLoader(context);
            }
            if (state is DeleteUserSuccess) {
              LoadingWidgets.hideLoader(context);
              HelperUtils.showSnackBarMessage(
                context,
                'userDeletedSuccessfully'.translate(context),
              );
              _clearUserSession(context);
              HelperUtils.killPreviousPages(context, Routes.login, null);
            }
            if (state is DeleteUserFailure) {
              LoadingWidgets.hideLoader(context);
              HelperUtils.showSnackBarMessage(context, state.errorMessage);
            }
          },
        ),
        BlocListener<LoginCubit, LoginState>(
          listener: (context, state) {
            if (state is LogoutInProgress) {
              LoadingWidgets.showLoader(context);
            }
            if (state is LogoutSuccess) {
              context.read<AuthenticationCubit>().signOut();
            }
          },
        ),
        BlocListener<AuthenticationCubit, AuthenticationState>(
          listener: (context, state) async {
            if (state is AuthenticationInitial) {
              LoadingWidgets.hideLoader(context);
              _clearUserSession(context);
              HelperUtils.killPreviousPages(context, Routes.login, null);
            }
            if (state is AuthenticationUserDeletionFailure) {
              LoadingWidgets.hideLoader(context);
              if (state.error case final FirebaseAuthException e
                  when e.code == 'requires-recent-login') {
                _handleRequiresRecentLoginEvent(context);
              } else {
                HelperUtils.showSnackBarMessage(
                  context,
                  state.error.toString(),
                );
              }
            }
            if (state is AuthenticationUserDeleted) {
              LoadingWidgets.hideLoader(context);
              context.read<DeleteUserCubit>().deleteUser();
            }
          },
        ),
        BlocListener<
          ActiveSubscriptionPackageCubit,
          ActiveSubscriptionPackageState
        >(
          listener: (context, state) {
            if (state is ActiveSubscriptionPackageLoading) {
              LoadingWidgets.showLoader(context);
            }
            if (state is ActiveSubscriptionPackageSuccess) {
              LoadingWidgets.hideLoader(context);
              if (state.activePackages.isNotEmpty) {
                Navigator.of(context).pushNamed(
                  Routes.activePlanScreen,
                  arguments: context.read<ActiveSubscriptionPackageCubit>(),
                );
              } else {
                Navigator.of(context).pushNamed(Routes.subscriptionScreen);
              }
            }
            if (state is ActiveSubscriptionPackageFailure) {
              LoadingWidgets.hideLoader(context);
              Navigator.of(context).pushNamed(Routes.subscriptionScreen);
            }
          },
        ),
      ],
      child: child,
    );
  }

  void _clearUserSession(BuildContext context) {
    AppSession.clear();
    HiveUtils.clear();
    HiveUtils.logoutUser(context);
    context.read<UserDetailsCubit>().clear();
    context.read<FavoriteCubit>().resetState();
    context.read<ItemReportListCubit>().clear();
    context.read<FetchJobApplicationCubit>().resetState();
    context.read<LeafLocationCubit>().clear();
    context.read<BuyingChatListCubit>().clear();
    context.read<SellerItemOffersCubit>().clear();
    context.read<BottomNavCubit>().changeIndex(0);
  }

  void _handleRequiresRecentLoginEvent(BuildContext context) async {
    final userDetails = HiveUtils.getUserDetails();
    if (userDetails.type == 'phone') {
      final result = await Navigator.pushNamed(
        context,
        Routes.deleteAccountVerification,
      );
      // If deletion was successful, result will be true
      if (result == true) {
        // Account deleted successfully, the verification screen already showed success message
        // Now cleanup and navigate to login
        _clearUserSession(context);
        HelperUtils.killPreviousPages(context, Routes.login, null);
      }
    } else {
      HelperUtils.showSnackBarMessage(
        context,
        'loginReqMsg'.translate(context),
      );
      context.read<LoginCubit>().logoutUser();
    }
  }
}
