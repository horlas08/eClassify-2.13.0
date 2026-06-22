import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/data/cubits/system/bottom_nav_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/lottie_utility.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';

class SuccessItemScreen extends StatefulWidget {
  final ItemModel model;
  final bool isEdit;

  const SuccessItemScreen({
    super.key,
    required this.model,
    required this.isEdit,
  });

  static Route route(RouteSettings settings) {
    Map? arguments = settings.arguments as Map?;
    return MaterialPageRoute(
      builder: (context) {
        return SuccessItemScreen(
          model: arguments!['model'],
          isEdit: arguments['isEdit'],
        );
      },
    );
  }

  @override
  _SuccessItemScreenState createState() => _SuccessItemScreenState();
}

class _SuccessItemScreenState extends State<SuccessItemScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _isSuccessShown = false;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  bool isBack = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      _isLoading = false;
      _isSuccessShown = true;
    }

    _slideController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1), // Adjust duration as needed
    );

    _slideAnimation =
        Tween<Offset>(
          begin: Offset(0, widget.isEdit ? 0 : 1.5), // Off-screen initially
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
        );

    // Simulate loading time
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted)
        setState(() {
          _isLoading = false;
        });
      // Show success animation after loading animation completes
      Future.delayed(const Duration(seconds: 0), () {
        if (mounted)
          setState(() {
            _isSuccessShown = true;
            Future.delayed(const Duration(seconds: 1), () {
              _slideController.forward();
            }); // Start slide animation
          });
      });
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _handleBackButtonPressed() {
    if (_isSuccessShown && _slideController.isAnimating) {
      setState(() {
        isBack = false;
      });
      // Don't allow popping while the animation is playing
      return;
    } else {
      // Navigate back to the home screen
      _navigateBackToHome();
      return;
    }
  }

  void _navigateToAdDetailsScreen() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      Routes.adDetailsScreen,
      (route) => route.isFirst,
      arguments: {'model': widget.model},
    );
  }

  void _navigateBackToHome() {
    if (mounted)
      Future.delayed(Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.popUntil(context, (route) => route.isFirst);
          context.read<BottomNavCubit>().changeIndex(0);
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: isBack,
      onPopInvokedWithResult: (didPop, result) async {
        // Handle back button press
        _handleBackButtonPressed();
      },
      child: Scaffold(
        body: Center(
          child: _isLoading
              ? LottieUtility.getAsset(LottieAssets.loading)
              : _isSuccessShown
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LottieUtility.getAsset(LottieAssets.success),
                    SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          SizedBox(height: 50),
                          if (!widget.isEdit)
                            CustomText(
                              'congratulations'.translate(context),
                              fontSize: context.font.extraLarge,
                              fontWeight: FontWeight.w600,
                              color: context.color.territoryColor,
                            ),
                          SizedBox(height: 18),
                          CustomText(
                            widget.isEdit
                                ? 'updatedSuccess'.translate(context)
                                : 'submittedSuccess'.translate(context),
                            color: context.color.textDefaultColor,
                            fontSize: context.font.larger,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 60),
                          Padding(
                            padding: Constant.appContentPadding,
                            child: UiUtils.buildButton(
                              context,
                              onPressed: _navigateToAdDetailsScreen,
                              buttonTitle: 'previewAd'.translate(context),
                            ),
                          ),
                          SizedBox(height: 25),
                          InkWell(
                            onTap: () {
                              _navigateBackToHome();
                            },
                            child: CustomText(
                              'backToHome'.translate(context),
                              textAlign: TextAlign.center,
                              fontSize: context.font.larger,
                              color: context.color.territoryColor,
                              underlineOrLineColor:
                                  context.color.territoryColor,
                              showUnderline: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : SizedBox(), // Placeholder
        ),
      ),
    );
  }
}
