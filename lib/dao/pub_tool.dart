import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';
import 'package:passkeep/model/password_info_model.dart';
import 'package:passkeep/model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PubTool {
  static const String magicNumber = '0x-pass-keep-0x9521';
  final SharedPreferences prefs;

  PubTool(this.prefs);

  /// 对传进来的 userModel 或者 passwordInfoModel 进行加密
  static String encrypt<T>(T model, String password) {
    assert(model is UserModel || model is PasswordInfoModel);

    String needEncrypt = magicNumber + json.encode(model);

    final Uint8List uint8list = md5.convert(utf8.encode(password)).bytes;
    final Key key = Key(uint8list);
    final IV iv = IV(uint8list.sublist(4));
    final Encrypter encrypter = Encrypter(AES(key));
    
    final Encrypted encrypted = encrypter.encrypt(needEncrypt, iv: iv);

    return encrypted.base64;
  }

  /// 返回null即解密失败
  static T decrypt<T>(String encryptedBase64, String password) {
    T model;
    String decrypted;
    assert(T.toString() == UserModel.modelKey()
           || T.toString() == PasswordInfoModel.modelKey());

    final Uint8List uint8list = md5.convert(utf8.encode(password)).bytes;
    final Key key = Key(uint8list);
    final IV iv = IV(uint8list.sublist(4));
    final Encrypter encrypter = Encrypter(AES(key));

    try {
      decrypted = encrypter.decrypt64(encryptedBase64, iv: iv);
    } on ArgumentError catch(e) {
      return null;
    }


    if(! decrypted.startsWith(magicNumber)) {
      // 魔数竟然对不上
      return null;
    }

    if( T.toString() == UserModel.modelKey())
      model = (UserModel.fromJson(
          json.decode(decrypted.substring(magicNumber.length)))
      as T);
    else
      model = (PasswordInfoModel.fromJson(
          json.decode(decrypted.substring(magicNumber.length)))
      as T);
    return model;
  }


  /// 从 SharedPreferences 获取base64传
  String
  getBase64FromSharedPreferences(String key){
    return prefs?.getString(key);
  }

  /// 将base64 写入 SharedPreferences 中
  Future<bool>
  setBase64ToSharedPreferences(String key, String base64) async {
    return prefs?.setString(key, base64)??false;
  }

  /// 删除一个key
  Future<bool>
  delKeySharedPreferences(String key) async {
    return prefs?.remove(key)??true;
  }
}
