import 'package:eClassify/data/cubits/referral/referral_points_history_cubit.dart';
import 'package:eClassify/ui/screens/profile_tab_screen/widgets/referral_points_tile.dart';
import 'package:eClassify/ui/screens/referral/widgets/referral_transaction_widget.dart';
import 'package:eClassify/ui/screens/widgets/q_error_widget.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/extensions/lib/extensions.dart';
import 'package:eClassify/utils/extensions/lib/gap.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReferralHistoryScreen extends StatefulWidget {
  const ReferralHistoryScreen({super.key});

  static Route<dynamic> route(RouteSettings routeSettings) {
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => BlocProvider(
        create: (_) => ReferralPointsHistoryCubit(),
        child: const ReferralHistoryScreen(),
      ),
    );
  }

  @override
  State<ReferralHistoryScreen> createState() => _ReferralHistoryScreenState();
}

class _ReferralHistoryScreenState extends State<ReferralHistoryScreen> {
  final ValueNotifier<bool> _showLoader = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    context.read<ReferralPointsHistoryCubit>().getTransactions();
  }

  @override
  void dispose() {
    _showLoader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('referralPoints'.translate(context))),
      body: Padding(
        padding: Constant.appContentPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 20,
          children: [
            ReferralPointsTile(),
            Text(
              'pointsHistory'.translate(context),
              style: context.titleMedium,
            ),
            Expanded(
              child:
                  BlocConsumer<
                    ReferralPointsHistoryCubit,
                    ReferralPointsHistoryState
                  >(
                    listener: (context, state) {
                      if (state is ReferralPointsHistorySuccess ||
                          state is ReferralPointsHistoryFailure) {
                        _showLoader.value = false;
                      }
                    },
                    builder: (context, state) {
                      if (state is ReferralPointsHistoryLoading) {
                        return Center(child: UiUtils.progress());
                      }
                      if (state is ReferralPointsHistoryFailure) {
                        return QErrorWidget(
                          error: state.error,
                          onRetry: () {
                            context
                                .read<ReferralPointsHistoryCubit>()
                                .getTransactions();
                          },
                        );
                      }
                      if (state is ReferralPointsHistorySuccess) {
                        if (state.transactions.isEmpty) {
                          return QErrorWidget.emptyData(
                            onRetry: () {
                              context
                                  .read<ReferralPointsHistoryCubit>()
                                  .getTransactions();
                            },
                          );
                        }

                        return NotificationListener<ScrollNotification>(
                          onNotification: (notification) {
                            if (notification.isNearBottom &&
                                context
                                    .read<ReferralPointsHistoryCubit>()
                                    .hasMore) {
                              _showLoader.value = true;
                              context
                                  .read<ReferralPointsHistoryCubit>()
                                  .getMoreTransactions();
                            }
                            return false;
                          },
                          child: RefreshIndicator(
                            onRefresh: () async {
                              context
                                  .read<ReferralPointsHistoryCubit>()
                                  .getTransactions();
                            },
                            child: ListView.separated(
                              itemCount: state.transactions.length + 1,
                              itemBuilder: (context, index) {
                                if (index == state.transactions.length) {
                                  return ValueListenableBuilder<bool>(
                                    valueListenable: _showLoader,
                                    builder: (context, value, child) {
                                      if (value) {
                                        return Center(
                                          child: UiUtils.progress(),
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  );
                                }
                                final transaction = state.transactions[index];
                                return ReferralTransactionWidget(
                                  transaction: transaction,
                                );
                              },
                              separatorBuilder: (_, _) => 10.vGap,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
