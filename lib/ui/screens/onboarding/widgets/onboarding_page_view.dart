import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:eClassify/utils/app_icon.dart';

List kOnboardingList = [
  {
    'svg': AppIcons.illustrators.onboardingA,
    'title': "onboarding_1_title",
    'description': "onboarding_1_des",
  },
  {
    'svg': AppIcons.illustrators.onboardingB,
    'title': "onboarding_2_title",
    'description': "onboarding_2_des",
  },
  {
    'svg': AppIcons.illustrators.onboardingC,
    'title': "onboarding_3_title",
    'description': "onboarding_3_des",
  },
];

class OnboardingPageView extends StatelessWidget {
  const OnboardingPageView({required this.controller, super.key});

  final PageController controller;

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller,
      itemCount: kOnboardingList.length,
      itemBuilder: (context, index) {
        final data = kOnboardingList[index];
        return SvgPicture.asset(data['svg'] as String);
      },
    );
  }
}
