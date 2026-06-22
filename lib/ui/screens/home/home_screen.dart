import 'package:collection/collection.dart';
import 'package:eClassify/data/cubits/auth/user_profile_cubit.dart';
import 'package:eClassify/data/cubits/banner/banner_ad_cubit.dart';
import 'package:eClassify/data/cubits/category/main_category_cubit.dart';
import 'package:eClassify/data/cubits/chat/chat_list_cubit.dart';
import 'package:eClassify/data/cubits/chat/seller_item_offers_cubit.dart';
import 'package:eClassify/data/cubits/currency/fetch_currencies_cubit.dart';
import 'package:eClassify/data/cubits/favorite/favorite_cubit.dart';
import 'package:eClassify/data/cubits/home/featured_section_cubit.dart';
import 'package:eClassify/data/cubits/home/home_items_cubit.dart';
import 'package:eClassify/data/cubits/home/home_screen_configuration_cubit.dart';
import 'package:eClassify/data/cubits/home/popular_categories_cubit.dart';
import 'package:eClassify/data/cubits/home/slider_cubit.dart';
import 'package:eClassify/data/cubits/location/leaf_location_cubit.dart';
import 'package:eClassify/data/cubits/system/bottom_nav_cubit.dart';
import 'package:eClassify/data/model/banner/banner_ad.dart';
import 'package:eClassify/data/model/home/home_section.dart';
import 'package:eClassify/data/model/location/leaf_location.dart';
import 'package:eClassify/ui/screens/google_banner_ad.dart';
import 'package:eClassify/ui/screens/home/mixins/root_location_resolver_mixin.dart';
import 'package:eClassify/ui/screens/home/widgets/all_items_widget.dart';
import 'package:eClassify/ui/screens/home/widgets/category/all_category_widget.dart';
import 'package:eClassify/ui/screens/home/widgets/category/popular_category_widget.dart';
import 'package:eClassify/ui/screens/home/widgets/featured_section/featured_section_widget.dart';
import 'package:eClassify/ui/screens/home/widgets/home_screen_shimmer.dart';
import 'package:eClassify/ui/screens/home/widgets/home_search.dart';
import 'package:eClassify/ui/screens/home/widgets/location_widget.dart';
import 'package:eClassify/ui/screens/home/widgets/slider_widget.dart';
import 'package:eClassify/ui/screens/widgets/banner_widget.dart';
import 'package:eClassify/ui/screens/widgets/q_error_widget.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/utils/app_session.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/lib/extensions.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({this.from, super.key});

  final String? from;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with
        AutomaticKeepAliveClientMixin,
        WidgetsBindingObserver,
        RootLocationResolverMixin {
  final ValueNotifier<bool> _isInitialLoad = ValueNotifier(
    AppSession.currentLocation == null,
  );

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    context.read<BottomNavCubit>().changeIndex(0);
    _loadHomeScreenData();
    if (HiveUtils.isUserAuthenticated()) {
      _loadUserData();
    }
  }

  @override
  void dispose() {
    _isInitialLoad.dispose();
    super.dispose();
  }

  void _loadUserData() {
    context.read<FavoriteCubit>().getFavorite();
    context.read<BuyingChatListCubit>().getChatUsers();
    context.read<SellerItemOffersCubit>().getOffers();
    if (widget.from != 'profile_screen') {
      context.read<UserProfileCubit>().getUserProfile();
    }
  }

  Future<void> _loadHomeScreenData() async {
    final location = AppSession.currentLocation;
    if (location == null) return;

    final fetchAllItems = switch (context
        .read<HomeConfigurationCubit>()
        .state) {
      HomeConfigurationSuccess(:final sections) => sections.any(
        (section) => section.type == HomeSectionType.allAds,
      ),
      _ => false,
    };

    context.read<FeaturedSectionCubit>().fetch(location: location);
    if (fetchAllItems) {
      context.read<HomeItemsCubit>().getHomeItems(location: location);
    }
    context.read<SliderCubit>().fetchSliders(location: location);
    context.read<MainCategoryCubit>().fetch(forceRefresh: true);
    context.read<PopularCategoriesCubit>().getCategories();
    context.read<FetchCurrenciesCubit>().fetchCurrencies();
    context.read<HomeBannerAdCubit>().fetchBanners();
    _isInitialLoad.value = false;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.colorScheme.backgroundColor,
        leadingWidth: double.maxFinite,
        leading: Padding(
          padding: EdgeInsets.symmetric(horizontal: Constant.horizontalPadding),
          child: LocationWidget(),
        ),
      ),
      body: BlocListener<LeafLocationCubit, LeafLocation?>(
        listener: (context, location) {
          _loadHomeScreenData();
        },
        child: BlocConsumer<HomeConfigurationCubit, HomeConfigurationState>(
          listener: (context, state) {
            if (state is HomeConfigurationLoading) {
              _isInitialLoad.value = true;
            }
            if (state is HomeConfigurationSuccess) {
              _loadHomeScreenData();
            }
            if (state is HomeConfigurationFailure) {
              Log.error(state.error.toString(), state.error, null);
              _isInitialLoad.value = false;
            }
          },
          builder: (context, state) {
            if (state is HomeConfigurationLoading) {
              return Padding(
                padding: Constant.appContentPadding,
                child: HomeScreenShimmer(),
              );
            }
            if (state is HomeConfigurationFailure) {
              return QErrorWidget(
                error: state.error,
                onRetry: () {
                  context.read<HomeConfigurationCubit>().getHomeConfiguration();
                },
              );
            }
            if (state is HomeConfigurationSuccess) {
              if (state.sections.isNullOrEmpty) {
                return QErrorWidget.emptyData(
                  onRetry: () {
                    context
                        .read<HomeConfigurationCubit>()
                        .getHomeConfiguration();
                  },
                );
              }

              return ValueListenableBuilder(
                valueListenable: _isInitialLoad,
                builder: (context, value, child) {
                  return value ? const HomeScreenShimmer() : child!;
                },
                child: Builder(
                  builder: (context) {
                    final banners = context
                        .watch<HomeBannerAdCubit>()
                        .homeBanners;

                    return RefreshIndicator(
                      onRefresh: _loadHomeScreenData,
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          // Only listen to notifications from the main CustomScrollView
                          if (notification.depth != 0) return false;

                          if (notification.isNearBottom &&
                              context.read<HomeItemsCubit>().hasMoreData) {
                            context.read<HomeItemsCubit>().getMoreHomeItems(
                              location: AppSession.currentLocation,
                            );
                          }
                          return false;
                        },
                        child: CustomScrollView(
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          slivers: _slivers(state.sections, banners),
                        ),
                      ),
                    );
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  List<Widget> _slivers(
    List<HomeSection> sections,
    List<HomeBannerAd> banners,
  ) {
    final bannersById = groupBy(
      banners,
      (b) => '${b.homeSectionId}_${b.placement.name}',
    );

    Widget? _resolveAdBannerWidget(String key) {
      final banner = bannersById[key]?.firstOrNull;

      return banner != null
          ? SliverToBoxAdapter(child: BannerWidget(bannerAd: banner))
          : null;
    }

    final slivers = List<Widget>.empty(growable: true);

    slivers.add(SliverToBoxAdapter(child: HomeSearchField()));

    for (final section in sections) {
      final aboveBanner = '${section.id}_${BannerPlacement.above.name}';
      final belowBanner = '${section.id}_${BannerPlacement.below.name}';

      slivers.addAll([
        ?_resolveAdBannerWidget(aboveBanner),
        ?_maybeAddGoogleBannerAd(section.type),
        HomeSectionFactory.getSectionWidget(section),
        ?_resolveAdBannerWidget(belowBanner),
      ]);
    }

    return slivers;
  }

  Widget? _maybeAddGoogleBannerAd(HomeSectionType type) {
    if (!Constant.systemSettings.isBannerAdEnabled) return null;
    if (type != HomeSectionType.allAds) return null;
    return SliverToBoxAdapter(child: GoogleBannerAd());
  }
}

class HomeSectionFactory {
  static Widget getSectionWidget(HomeSection section) {
    return switch (section.type) {
      HomeSectionType.categoryList => SliverToBoxAdapter(
        child: const AllCategoryWidget(),
      ),
      HomeSectionType.slider => SliverToBoxAdapter(child: const SliderWidget()),
      HomeSectionType.popularCategories => SliverToBoxAdapter(
        child: const PopularCategoryWidget(),
      ),
      HomeSectionType.featuredSection => const FeaturedSectionWidget(),
      HomeSectionType.allAds => const AllItemsWidget(),
    };
  }
}
