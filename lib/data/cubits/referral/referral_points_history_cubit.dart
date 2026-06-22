import 'package:eClassify/data/model/referral/referral_transaction.dart';
import 'package:eClassify/data/repositories/referral/referral_repository.dart';
import 'package:eClassify/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ReferralPointsHistoryState {}

class ReferralPointsHistoryInitial extends ReferralPointsHistoryState {}

class ReferralPointsHistoryLoading extends ReferralPointsHistoryState {}

class ReferralPointsHistorySuccess extends ReferralPointsHistoryState {
  ReferralPointsHistorySuccess({required this.transactions});

  final List<ReferralTransaction> transactions;
}

class ReferralPointsHistoryFailure extends ReferralPointsHistoryState {
  ReferralPointsHistoryFailure({required this.error});

  final Object? error;
}

class ReferralPointsHistoryCubit extends Cubit<ReferralPointsHistoryState> {
  ReferralPointsHistoryCubit() : super(ReferralPointsHistoryInitial());

  int page = 1;
  bool hasMore = true;

  Future<void> getTransactions() async {
    try {
      emit(ReferralPointsHistoryLoading());

      final data = await ReferralRepository.instance.getReferralTransactions(
        page: 1,
      );

      emit(ReferralPointsHistorySuccess(transactions: data.modelList));
      hasMore = data.modelList.length < data.total;
      if (hasMore) ++page;
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(ReferralPointsHistoryFailure(error: e));
    }
  }

  Future<void> getMoreTransactions() async {
    try {
      final data = await ReferralRepository.instance.getReferralTransactions(
        page: page + 1,
      );

      final previousTransactions =
          (state as ReferralPointsHistorySuccess).transactions;
      emit(
        ReferralPointsHistorySuccess(
          transactions: previousTransactions + data.modelList,
        ),
      );
      hasMore =
          (previousTransactions.length + data.modelList.length) < data.total;
      if (hasMore) ++page;
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(ReferralPointsHistoryFailure(error: e));
    }
  }
}
