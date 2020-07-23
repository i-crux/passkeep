
import 'package:passkeep/dao/pub_tool.dart';
import 'package:passkeep/model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserModelDao {
  final SharedPreferences prefs;
  final String userName;
  final String password;
  final PubTool _pubTool;
  bool noData = false;

  UserModelDao({this.prefs, this.userName, this.password})
      : _pubTool = PubTool(prefs);

  UserModel fetch() {
    String base64UserModel =
      _pubTool.getBase64FromSharedPreferences(userName);
    if(base64UserModel == null) {
      noData = true;
      return null;
    }
    noData = false;
    return PubTool.decrypt<UserModel>(base64UserModel, password);
  }

  Future<bool> write(UserModel userModel) async {
    String base64UserModel = PubTool.encrypt<UserModel>(userModel, password);
    bool result = await _pubTool.setBase64ToSharedPreferences(userName,
        base64UserModel);
    if(result)
      noData = false;
    return result;
  }

  Future<bool> delete() async {
    noData = true;
    return _pubTool.delKeySharedPreferences(userName);
  }
}
