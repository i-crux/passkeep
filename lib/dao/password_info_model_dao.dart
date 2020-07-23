
import 'package:passkeep/dao/pub_tool.dart';
import 'package:passkeep/model/password_info_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PasswordInfoModelDao {
  final SharedPreferences prefs;
  final String userName;
  final String password;
  final PubTool _pubTool;
  bool noData = false;

  PasswordInfoModelDao({this.prefs, this.userName, this.password})
      : _pubTool = PubTool(prefs);

  PasswordInfoModel fetch() {
    String base64PasswordInfoModel =
      _pubTool.getBase64FromSharedPreferences('$userName.$password');
    if(base64PasswordInfoModel == null) {
      noData = true;
      return null;
    }
    noData = false;
    return PubTool.decrypt<PasswordInfoModel>(base64PasswordInfoModel,
        '$userName.$password');
  }

  Future<bool> write(PasswordInfoModel passwordInfoModel) async {
    String base64PasswordInfoModel = PubTool.encrypt<PasswordInfoModel>(
        passwordInfoModel, '$userName.$password');
    bool result = await _pubTool.setBase64ToSharedPreferences(
                          '$userName.$password', base64PasswordInfoModel);
    if(result)
      noData = false;
    return result;
  }

  Future<bool> delete() async {
    noData = true;
    return _pubTool.delKeySharedPreferences('$userName.$password');
  }
}
