import 'package:flutter/material.dart';
import 'package:passkeep/dao/password_info_model_dao.dart';
import 'package:passkeep/dao/user_model_dao.dart';
import 'package:passkeep/model/user_model.dart';
import 'package:passkeep/pages/error_page.dart';
import 'package:passkeep/pages/password_manage_page.dart';
import 'package:passkeep/public_function/make_logo.dart';
import 'package:passkeep/widget/tow_input_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  static const Brightness _appSelectedTheme = Brightness.dark;
  String _account;
  // 账号匡焦点事件
  FocusNode _accountFocusNode = FocusNode();
  // 账号匡控制器
  TextEditingController _accountController = TextEditingController();
  // 用户密码
  String _password;
  // 密码匡焦点事件
  FocusNode _passwordFocusNode = FocusNode();
  // 密码匡控制器
  TextEditingController _passwordController = TextEditingController();

  // 登录失败的原因
  String _loginFailedReason = " ";
  // 是否登录失败
  bool _isLoginFailed = false;

  // k-v 数据库
  SharedPreferences _prefs;
  bool kvInitFailed = false;

  @override
  void initState() {
    _accountFocusNode.addListener(() {
      if (_accountFocusNode.hasFocus) {
        // TextField has focus
        if(_isLoginFailed) {
          setState(() {
            _isLoginFailed = false;
            _loginFailedReason = ' ';
          });
        }
      }
    });
    _passwordFocusNode.addListener(() {
      if (_passwordFocusNode.hasFocus) {
        // TextField has focus
        if(_isLoginFailed) {
          setState(() {
            _isLoginFailed = false;
            _loginFailedReason = ' ';
          });
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _accountFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if(kvInitFailed) {
      return ErrorPage();
    }

    if(_prefs == null) {
      SharedPreferences.getInstance().then((prefs){
        _prefs = prefs;
      }).catchError((e){
        setState(() {
          kvInitFailed = true;
        });
      });
    }
    return Scaffold(
      appBar: _appBar,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: ListView(
            children: <Widget>[
              _logo,
              _welcomeWords,
              _hintInfo,
              TowInputBar(
                getInputInfo: (account, password){
                  setState(() {
                    _account = account;
                    _password = password;
                    _login();
                  });
                },
                upTitle: "账号",
                downTitle: "密码",
                upHint: "请输入账号",
                downHint: "请输入密码",
                downType: InputFieldType.secret,
                brightness: _appSelectedTheme,
                upFocusNode: _accountFocusNode,
                upController: _accountController,
                downFocusNode: _passwordFocusNode,
                downController: _passwordController,
                buttonTitle: "登录",
                longPress: (account, password) {
                  _account = account;
                  _password = password;
                  _deleteAccount();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget get _appBar {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0, //去掉Appbar底部阴影
    );
  }

  Widget get _logo {
    return makeLogo();
  }

  Widget get _welcomeWords {
    return Column(
      children: <Widget>[
        Container(
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.only(left:50, top: 30),
          child: Text(
            "欢迎回来",
            style: TextStyle(
              fontSize: 25,
              color: _appSelectedTheme == Brightness.light ?
              Colors.black : Colors.white60,
              fontFamily: "simhei",
            ),
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.only(left:50, top: 0),
          child: Text(
            "登录以继续",
            style: TextStyle(
              fontSize: 15,
              color: _appSelectedTheme == Brightness.light ?
              Colors.blue : Colors.deepOrange,
              fontFamily: "simhei",
            ),
          ),
        ),
      ],
    );
  }

  Widget get _hintInfo {
    return  Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(top: 30, bottom: 15),
      child: Text(
        _isLoginFailed ? _loginFailedReason : " ",
        style: TextStyle(
          fontSize: 15,
          color: Colors.redAccent,
        ),
      ),
    );
  }

  void _login() {
    if(_checkInput() == false) {
      return;
    }

    while(_prefs == null) {
      Future.delayed(Duration(milliseconds: 100)).then((_) {
        if(_prefs != null) {
          _doLogin();
          return;
        }
      });
    }

    _doLogin();
  }

  void _doLogin() {
    _accountController.clear();
    _passwordController.clear();

    UserModelDao userModelDao = UserModelDao(
      prefs: _prefs,
      userName: _account,
      password: _password,
    );

    UserModel userModel = userModelDao.fetch();
    
    if(userModelDao.noData == true) {
      /// 新账号
      userModel = UserModel(
        userName: _account,
        password: _password,
        theme: _appSelectedTheme,
        rememberPassword: false,
      );
      userModelDao.write(userModel).then((result){
        if(result == false) {
          setState(() {
            kvInitFailed = true;
          });
          return;
        }
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => PasswordManagePage(
            account: _account,
            password: _password,
            theme: _appSelectedTheme,
          ),
        ));
      }).catchError((e){
        setState(() {
          kvInitFailed = true;
        });
        return;
      });
    } else {
      /// 已有账号
      if(userModel == null){
        /// 登录失败
        setState(() {
          _isLoginFailed = true;
          _loginFailedReason = '无效的密码';
        });
        return;
      } else {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => PasswordManagePage(
            account: _account,
            password: _password,
            theme: _appSelectedTheme,
          ),
        ));
      }
    }
  }

  void _deleteAccount() {
    if(_checkInput() == false) {
      return;
    }

    while(_prefs == null) {
      Future.delayed(Duration(milliseconds: 100)).then((_) {
        if(_prefs != null) {
          _doDeleteAccount();
        }
      });
    }
    _doDeleteAccount();
  }

  void _doDeleteAccount() {
    _accountController.clear();
    _passwordController.clear();

    UserModelDao userModelDao = UserModelDao(
      prefs: _prefs,
      userName: _account,
      password: _password,
    );

    UserModel userModel = userModelDao.fetch();
    if(userModelDao.noData == true) {
      setState(() {
        _isLoginFailed = true;
        _loginFailedReason = '账号 $_account 不存在';
      });
      return;
    }
    if(userModel == null) {
      setState(() {
        _isLoginFailed = true;
        _loginFailedReason = '无效的密码';
      });
      return;
    }

    userModelDao.delete().then((result){
      if(!result) {
        setState(() {
          kvInitFailed = true;
        });
      }
    }).catchError((e){
      setState(() {
        kvInitFailed = true;
      });
    });
    _deleteAccountRecord();
  }

  void _deleteAccountRecord() {
    PasswordInfoModelDao _passwordInfoModelDao;

    SharedPreferences.getInstance().then((prefs){
      _passwordInfoModelDao = PasswordInfoModelDao(
        prefs: prefs,
        userName: _account,
        password: _password,
      );
      _deleteKv(_passwordInfoModelDao);
      setState(() {
        _isLoginFailed = true;
        _loginFailedReason = '账号 $_account 已删除';
      });
    }).catchError((e){
      setState(() {
        kvInitFailed = true;
      });
    });
  }

 void _deleteKv(PasswordInfoModelDao _passwordInfoModelDao) {
    _passwordInfoModelDao.delete().then((result){
      if(!result) {
        setState(() {
          kvInitFailed = true;
        });
      }
    }).catchError((e){
      setState(() {
        kvInitFailed = true;
      });
    });
  }

  bool _checkInput() {
    _accountFocusNode.unfocus();
    _passwordFocusNode.unfocus();
    if(_account == null || _account.length == 0) {
      setState(() {
        _isLoginFailed = true;
        _loginFailedReason = "用户名不能为空";
      });
      return false;
    }
    if( _password == null || _password.length < 8) {
      setState(() {
        _isLoginFailed = true;
        _loginFailedReason = "密码长度至少8位";
      });
      return false;
    }
    return true;
  }
}
