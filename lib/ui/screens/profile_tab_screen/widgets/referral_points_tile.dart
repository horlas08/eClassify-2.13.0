import 'package:eClassify/data/cubits/auth/user_profile_cubit.dart';
import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/utils/app_icon.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReferralPointsTile extends StatelessWidget {
  const ReferralPointsTile({this.onTap, this.trailing, super.key});

  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final referralPoints = context.select<UserProfileCubit, num>(
      (cubit) => switch (cubit.state) {
        final UserProfileSuccess s => s.user.referralPoints ?? 0,
        _ => 0,
      },
    );
    return ListTile(
      onTap: onTap,
      leading: CustomImage(
        src: AppIcons.profile.referralPoints,
        size: Size.square(40),
      ),
      title: Text('referralPoints'.translate(context)),
      subtitle: Text('${referralPoints}'),
      trailing: trailing,
    );
  }
}
