/*
 * 保存 shared_preferences 使用的关键字为 md5('userName.password')
 * 这个是保存在 shared_preferences 中的 json 字符串(加密前)
 * {
 *  'websiteName.userID':
 *      {'websiteName': 'website_name', 'userID' : 'use_id',
 *       'password':'password', 'iteration': '123',
 *       'comment' : 'comment'},
 *  ...
 * }
 * 加密密钥会使用 userName 和 password 在运行时生成,
 * 会对用户密码模型的json进行 AES 加密
 */
class PasswordRecord {
  String websiteName;
  String userID;
  String password;
  int iteration;
  String comment;

  PasswordRecord({this.websiteName, this.userID, this.password,
                 this.iteration, this.comment});
  factory PasswordRecord.fromJson(Map<String, dynamic> json) {
    return PasswordRecord(
      websiteName: json['websiteName'],
      userID: json['userID'],
      password: json['password'],
      iteration: json['iteration'],
      comment: json['comment'],
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = Map<String, dynamic>();
    json['websiteName'] = websiteName;
    json['userID'] = userID;
    json['password'] = password;
    json['iteration'] = iteration;
    json['comment'] = comment;
    return json;
  }
}

class PasswordInfoModel {
  final Map<String, PasswordRecord>  passwordInfo;

  PasswordInfoModel({this.passwordInfo});

  factory PasswordInfoModel.fromJson(Map<String, dynamic> json) {
    Map<String, PasswordRecord> passwordInfo = Map<String, PasswordRecord> ();
    json.forEach((k, v) {
      passwordInfo[k] = PasswordRecord.fromJson(v);
    });
    return PasswordInfoModel(passwordInfo: passwordInfo);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = Map<String, dynamic>();
    passwordInfo.forEach((k, v){
      json[k] = v.toJson();
    });
    return json;
  }

  static String modelKey() {
    return 'PasswordInfoModel';
  }
}