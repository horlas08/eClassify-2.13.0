import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/seller/fetch_verification_request_cubit.dart';
import 'package:eClassify/data/model/user/verification_request.dart';
import 'package:eClassify/ui/screens/profile_tab_screen/widgets/follow_users_count_widget.dart';
import 'package:eClassify/ui/screens/widgets/bottom_navigation_bar/svg_color_mapper.dart';
import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/app_icon.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/extensions/lib/extensions.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final user = HiveUtils.getUserDetails();
    final isAuthenticated = HiveUtils.isUserAuthenticated();

    final config = switch (isAuthenticated) {
      true => (title: user.name, subtitle: user.email),
      false => (
        title: 'guestUser'.translate(context),
        subtitle: 'loginFirst'.translate(context),
      ),
    };

    return Card.filled(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          spacing: 10,
          children: [
            _UserAvatar(image: user.profile),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (config.title.isNotNullAndNotEmpty)
                    Row(
                      spacing: 2,
                      children: [
                        Text(config.title!, style: context.labelLarge.bold),
                        if (HiveUtils.isUserAuthenticated())
                          const _VerifiedIcon(),
                      ],
                    ),
                  if (config.subtitle.isNotNullAndNotEmpty)
                    Text(config.subtitle!, style: context.bodyMedium),
                  if (isAuthenticated) FollowUsersCountWidget(),
                ],
              ),
            ),
            if (!isAuthenticated)
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.colorScheme.onSurface,
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.login);
                },
                child: Text('login'.translate(context)),
              ),
          ],
        ),
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({this.image});

  final String? image;

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = HiveUtils.isUserAuthenticated();

    return GestureDetector(
      onTap: () {
        if (isAuthenticated) {
          Navigator.of(
            context,
          ).pushNamed(Routes.completeProfile, arguments: {'from': 'profile'});
        }
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: context.colorScheme.surface,
            child: CustomImage(
              src: image,
              size: Size.square(64),
              radius: 32,
              errorImage: CustomImage(
                src: AppIcons.profile.defaultPerson,
                svgColorMapper: SvgColorMapper(),
                radius: 32,
              ),
            ),
          ),
          if (isAuthenticated)
            PositionedDirectional(
              end: 0,
              bottom: 0,
              child: CircleAvatar(
                radius: 12,
                backgroundColor: context.colorScheme.primary,
                child: Icon(
                  Icons.edit,
                  size: 16,
                  color: context.colorScheme.onPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _VerifiedIcon extends StatelessWidget {
  const _VerifiedIcon();

  @override
  Widget build(BuildContext context) {
    final user = HiveUtils.getUserDetails();
    final isVerified = context.select<VerificationRequestCubit, bool>(
      (cubit) => switch (cubit.state) {
        final VerificationRequestSuccess s
            when s.request.status == VerificationRequestStatus.approved =>
          true,
        _ => user.isVerified ?? false,
      },
    );
    if (isVerified) {
      return Icon(
        Icons.verified,
        size: 16,
        color: context.colorScheme.tertiary,
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
