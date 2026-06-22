import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/followers/follow_user_list_cubit.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FollowUsersCountWidget extends StatelessWidget {
  const FollowUsersCountWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final followersCount = context.select<FollowersListCubit, int>(
      (cubit) => switch (cubit.state) {
        final FollowUsersListSuccess s => s.totalCount,
        _ => 0,
      },
    );

    final followingCount = context.select<FollowingListCubit, int>(
      (cubit) => switch (cubit.state) {
        final FollowUsersListSuccess s => s.totalCount,
        _ => 0,
      },
    );

    Log.info('$followingCount $followersCount');

    if(followersCount == 0 && followingCount == 0) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          Routes.followersScreen,
          arguments: {
            'title': 'myFollowers'.translate(context),
            'default_tab': 0,
          },
        );
      },
      child: Row(
        children: [
          Text('${followersCount} ${'followers'.translate(context)}'),
          SizedBox(
            height: 10,
            child: VerticalDivider(color: context.mutedColor,),
          ),
          Text('${followingCount} ${'following'.translate(context)}'),
        ],
      ),
    );
  }
}
