import 'package:flutter/material.dart';

/*
 * 保存 shared_preferences 使用的关键字为 md5('userName')
 * 这个是保存在 shared_preferences 中的 json 字符串(加密前)
 * {
 *  'userName': 'user_name',
 *  'password': 'password',
 *  'theme': '[dark|light]',
 *  'rememberPassword': true|false
 * }
 * 加密密钥会使用 password 在运行时生成,
 * 会对用户模型的json进行 AES加密
 */

class UserModel {
  final String userName;
  final String password;
  final Brightness theme;
  bool rememberPassword;

  UserModel({this.userName, this.password,
            this.theme, this.rememberPassword});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userName: json['userName'],
      password: json['password'],
        theme: json['theme'] == 'dart' ? Brightness.dark : Brightness.light,
      rememberPassword: json['rememberPassword']
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = Map<String, dynamic> ();
    json['userName'] = userName;
    json['password'] = password;
    json['theme'] = (theme == Brightness.dark ? 'dart' : 'light');
    json['rememberPassword'] = rememberPassword;
    return json;
  }

  static String modelKey() {
    return "UserModel";
  }
}