import 'package:eClassify/data/model/system_settings.dart';
import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/json_helper.dart';
import 'package:eClassify/utils/log.dart';

class SystemRepository {
  SystemRepository._();
  static final _instance = SystemRepository._();
  static SystemRepository get instance => _instance;

  Future<SystemSettings> getSystemSettings() async {
    try {
      final response = await Api.get(url: Api.getSystemSettingsApi);
      return JsonHelper.parseObject(
        response['data'] as Json,
        SystemSettings.fromJson,
      );
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }
}
