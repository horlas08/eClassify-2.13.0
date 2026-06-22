import 'package:eClassify/data/model/referral/referral_summary.dart';
import 'package:eClassify/data/repositories/referral/referral_repository.dart';
import 'package:eClassify/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// NOTE: This cubit is not used anywhere in the codebase as we already get
// summary of user's referral from user's profile. Hence, to reduce the API
// call we no longer depend on this cubit. In case, we need more data for the
// referral feature, this cubit can be used for that.

abstract class ReferralSummaryState {}

class ReferralSummaryInitial extends ReferralSummaryState {}

class ReferralSummaryLoading extends ReferralSummaryState {}

class ReferralSummarySuccess extends ReferralSummaryState {
  ReferralSummarySuccess({required this.summary});

  final ReferralSummary summary;
}

class ReferralSummaryFailure extends ReferralSummaryState {
  ReferralSummaryFailure({required this.message});

  final String message;
}

class ReferralSummaryCubit extends Cubit<ReferralSummaryState> {
  ReferralSummaryCubit() : super(ReferralSummaryInitial());

  Future<void> getReferralSummary() async {
    try {
      emit(ReferralSummaryLoading());

      final summary = await ReferralRepository.instance.getReferralSummary();

      emit(ReferralSummarySuccess(summary: summary));
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(ReferralSummaryFailure(message: e.toString()));
    }
  }
}
