import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eClassify/app/routes.dart';
import 'package:eClassify/app_config.dart';
import 'package:eClassify/data/cubits/home/home_screen_configuration_cubit.dart';
import 'package:eClassify/data/cubits/system/fetch_language_cubit.dart';
import 'package:eClassify/data/cubits/system/language_cubit.dart';
import 'package:eClassify/data/cubits/system/system_settings_cubit.dart';
import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/ui/screens/widgets/errors/no_internet.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/utils/app_icon.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({this.itemSlug, super.key, this.sellerId});

  //Used when the app is terminated and then is opened using deep link, in which case
  //the main route needs to be added to navigation stack, previously it directly used to
  //push adDetails route.
  final String? itemSlug;
  final String? sellerId;

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  bool isTimerCompleted = false;
  bool isSettingsLoaded = false;
  bool isLanguageLoaded = false;
  bool _hasNavigated = false;
  late StreamSubscription<List<ConnectivityResult>> subscription;
  bool hasInternet = true;

  @override
  void initState() {
    super.initState();
    subscription = Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        hasInternet = (!result.contains(ConnectivityResult.none));
      });
      if (hasInternet) {
        context.read<SystemSettingsCubit>().getSystemSettings();
        context.read<HomeConfigurationCubit>().getHomeConfiguration();
        startTimer();
      }
    });
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  Future<void> _getDefaultLanguage({
    required String defaultCode,
    required String? currentCode,
  }) async {
    try {
      final languageData = Map<String, dynamic>.from(
        HiveUtils.getLanguage() ?? {},
      );
      // Check the language code that settings api returned the response in
      // if the language code is equal to the locally stored language then we re-fetch
      // the language for same code to retrieve the latest json values.
      // If the currentCode is not equal then it likely means that the language cached
      // locally is no longer available on the admin panel, hence in that case we will
      // fetch the default language data and use that for rest of the app
      if (languageData.isNotEmpty && languageData['code'] == currentCode) {
        context.read<FetchLanguageCubit>().getLanguage(
          currentCode ?? defaultCode,
        );
      } else {
        context.read<FetchLanguageCubit>().getLanguage(defaultCode);
      }
    } catch (e, st) {
      context.read<FetchLanguageCubit>().getLanguage(defaultCode);
      log("Error while load default language $e");
      log('$st');
    }
  }

  Future<void> startTimer() async {
    Timer(const Duration(seconds: 1), () {
      isTimerCompleted = true;
      navigateCheck();
    });
  }

  void navigateCheck() {
    if (_hasNavigated) return;
    if (isTimerCompleted && isSettingsLoaded && isLanguageLoaded) {
      _hasNavigated = true;
      navigateToScreen();
    }
  }

  void navigateToScreen() async {
    if (Constant.systemSettings.maintenanceMode) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(Routes.maintenanceMode);
        }
      });
    } else if (HiveUtils.isUserFirstTime()) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(Routes.onboarding);
        }
      });
    } else if (HiveUtils.isUserAuthenticated()) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          //We pass slug only when the user is authenticated otherwise drop the slug
          Navigator.of(context).pushReplacementNamed(
            Routes.main,
            arguments: {
              'from': "main",
              "slug": widget.itemSlug,
              "sellerId": widget.sellerId,
            },
          );
        }
      });
    } else {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          if (HiveUtils.isUserSkip()) {
            Navigator.of(context).pushReplacementNamed(
              Routes.main,
              arguments: {
                'from': "main",
                "slug": widget.itemSlug,
                "sellerId": widget.sellerId,
              },
            );
          } else {
            Navigator.of(context).pushReplacementNamed(Routes.login);
          }
        }
      });
    }
  }

  Widget? _companyLogo() {
    if (AppConfig.showCompanyLogo) {
      return SafeArea(
        child: SizedBox(
          height: kToolbarHeight,
          child: Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: CustomImage(
                src: AppIcons.branding.company,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      );
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return hasInternet
        ? BlocListener<FetchLanguageCubit, FetchLanguageState>(
            listener: (context, state) {
              if (state is FetchLanguageSuccess) {
                Map<String, dynamic> map = state.toMap();

                var data = map['file_name'];
                map['data'] = data;
                map.remove("file_name");

                HiveUtils.storeLanguage(map);
                context.read<LanguageCubit>().changeLanguages(map);
                isLanguageLoaded = true;
                if (mounted) {
                  navigateCheck();
                }
              }
              if (state is FetchLanguageFailure) {
                HelperUtils.showSnackBarMessage(context, state.errorMessage);
              }
            },
            child: BlocListener<SystemSettingsCubit, SystemSettingsState>(
              listener: (context, state) {
                if (state.settings != null) {
                  Constant.isDemoModeOn = state.settings!.demoMode;
                  _getDefaultLanguage(
                    defaultCode: state.settings!.defaultLanguageCode,
                    currentCode: state.settings!.currentLanguageCode,
                  );
                  isSettingsLoaded = true;
                  navigateCheck();
                }
                if (state.error != null) {
                  log('${state.error.toString()}');
                }
              },
              child: Scaffold(
                backgroundColor: context.colorScheme.primary,
                bottomNavigationBar: _companyLogo(),
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 10,
                  children: [
                    /// You can use any image format here
                    /// For formats other than .svg, provide the full
                    /// assets path (e.g. logo.png, company_logo.jpeg).
                    CustomImage(
                      src: AppIcons.branding.logo,
                      size: Size.square(150),
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            ),
          )
        : Material(
            child: Center(
              child: NoInternet(
                onRetry: () {
                  setState(() {});
                },
              ),
            ),
          );
  }
}
