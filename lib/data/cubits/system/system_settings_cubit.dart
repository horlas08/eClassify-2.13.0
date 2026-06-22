import 'package:eClassify/data/model/system_settings.dart';
import 'package:eClassify/data/repositories/system_repository.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SystemSettingsState {
  SystemSettingsState({this.settings, this.isLoading = false, this.error});

  final SystemSettings? settings;
  final bool isLoading;
  final Object? error;

  SystemSettingsState copyWith({
    SystemSettings? settings,
    bool? isLoading,
    Object? error,
  }) => SystemSettingsState(
    settings: settings ?? this.settings,
    isLoading: isLoading ?? this.isLoading,
    error: error ?? this.error,
  );
}

class SystemSettingsCubit extends Cubit<SystemSettingsState> {
  SystemSettingsCubit() : super(SystemSettingsState());

  Future<void> getSystemSettings() async {
    try {
      emit(state.copyWith(isLoading: true, error: null));

      final settings = await SystemRepository.instance.getSystemSettings();

      // This isn't the ideal way to access system settings everywhere in the codebase
      // but we can't rely just on this cubit to retrieve the settings because
      // system settings instance is required in places where passing context
      // would violate the boundaries of UI and Service layer. Hence this is
      // only the sane solution as of now to avoid complicating it much
      // TODO(I): Find a better way to access system settings
      Constant.systemSettings = settings;

      emit(state.copyWith(isLoading: false, settings: settings));
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(state.copyWith(isLoading: false, error: e));
    }
  }
}
