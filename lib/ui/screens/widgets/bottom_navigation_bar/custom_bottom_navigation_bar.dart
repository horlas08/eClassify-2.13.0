import 'package:eClassify/data/cubits/chat/chat_list_cubit.dart';
import 'package:eClassify/data/cubits/chat/seller_item_offers_cubit.dart';
import 'package:eClassify/data/cubits/system/bottom_nav_cubit.dart';
import 'package:eClassify/ui/screens/widgets/bottom_navigation_bar/svg_color_mapper.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/app_icon.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

/// Custom Navigation bar that gives space to the centerDocked FAB button
class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  State<CustomBottomNavigationBar> createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  final items = [
    _BottomNavigationItem(
      icon: AppIcons.menu.home,
      activeIcon: AppIcons.menu.homeActive,
      label: 'homeTab',
    ),
    _BottomNavigationItem(
      icon: AppIcons.menu.chat,
      activeIcon: AppIcons.menu.chatActive,
      label: 'chat',
    ),
    // This null value is to be used for giving space at the center of bottom nav to avoid placing items behind the FAB
    null,
    _BottomNavigationItem(
      icon: AppIcons.menu.myAds,
      activeIcon: AppIcons.menu.myAdsActive,
      label: 'myAdsTab',
    ),
    _BottomNavigationItem(
      icon: AppIcons.menu.profile,
      activeIcon: AppIcons.menu.profileActive,
      label: 'profileTab',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // We need SafeArea here because we are not using conventional BottomNavigationBar
    // widget, hence it will not automatically add padding on Android 15 edge-to-edge mode
    double bottomNavHeight = kBottomNavigationBarHeight;
    bottomNavHeight += MediaQuery.paddingOf(context).bottom;

    return SizedBox(
      height: bottomNavHeight,
      child: ColoredBox(
        color: context.color.secondaryColor,
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: BlocBuilder<BottomNavCubit, int>(
              builder: (context, selectedIndex) {
                // Track the index of each child.
                // We do it manually as we are using SizedBox and we don't want
                // it to occupy any index, hence that is why we can't use conventional
                // NavigationBar or BottomNavigationBar because they will assign index
                // to SizedBox also
                int itemIndex = 0;
                return Row(
                  children: items.map((item) {
                    if (item == null) return SizedBox(width: 25);
                    final index = itemIndex++;
                    Widget child = _BottomNavigationItemWidget(
                      item: item,
                      selected: selectedIndex == index,
                      onPressed: () {
                        if (item.label case == 'chat' || 'myAdsTab') {
                          UiUtils.checkUser(
                            onNotGuest: () {
                              context.read<BottomNavCubit>().changeIndex(index);
                            },
                            context: context,
                          );
                        } else {
                          context.read<BottomNavCubit>().changeIndex(index);
                        }
                      },
                    );
                    if (item.label case 'chat') {
                      child = _DynamicChatIconWithBadge(child: child);
                    }
                    return Expanded(child: child);
                  }).toList(),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavigationItemWidget extends StatelessWidget {
  _BottomNavigationItemWidget({
    required this.item,
    required this.selected,
    required this.onPressed,
  });

  final _BottomNavigationItem item;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        shape: LinearBorder.none,
        padding: EdgeInsets.zero,
      ),
      onPressed: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox.square(
            dimension: 20,
            child: SvgPicture.asset(
              selected ? item.activeIcon : item.icon,
              colorMapper: SvgColorMapper(),
              colorFilter: selected
                  ? null
                  : ColorFilter.mode(
                      context.color.textLightColor,
                      BlendMode.srcIn,
                    ),
            ),
          ),
          Text(
            item.label.translate(context),
            textAlign: TextAlign.center,
            style: context.labelMedium.withColor(
              selected ? context.colorScheme.onSurface : context.mutedColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavigationItem {
  _BottomNavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final String icon;
  final String activeIcon;
  final String label;
}

class _DynamicChatIconWithBadge extends StatelessWidget {
  const _DynamicChatIconWithBadge({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final sellerCount = context.select<SellerItemOffersCubit, int>((
      offerCubit,
    ) {
      return switch (offerCubit.state) {
        final SellerItemOffersSuccess s when s.offers.isNotEmpty =>
          s.offers.fold(0, (value, ele) => value + ele.unreadCount),
        _ => 0,
      };
    });

    final buyerCount = context.select<BuyingChatListCubit, int>((buyingCubit) {
      return switch (buyingCubit.state) {
        final ChatListSuccess b when b.users.isNotEmpty => b.users.fold(
          0,
          (value, ele) => value + ele.unreadCount,
        ),
        _ => 0,
      };
    });

    final totalUnread = sellerCount + buyerCount;
    final label = switch (totalUnread) {
      >= 100 => '99+',
      _ => totalUnread.toString(),
    };

    return switch (totalUnread) {
      > 0 => Badge(
        alignment: AlignmentDirectional.topCenter.add(
          AlignmentGeometry.directional(.1, 0),
        ),
        backgroundColor: context.colorScheme.tertiary,
        label: Text(
          label,
          style: context.labelSmall.withColor(context.colorScheme.onPrimary),
        ),
        child: child,
      ),
      _ => child,
    };
  }
}
