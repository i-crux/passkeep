import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:passkeep/dao/password_info_model_dao.dart';
import 'package:passkeep/model/password_info_model.dart';
import 'package:passkeep/pages/error_page.dart';
import 'package:passkeep/widget/info_card.dart';
import 'package:passkeep/widget/search_bar.dart';
import 'package:passkeep/widget/tow_input_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

class PasswordManagePage extends StatefulWidget {
  final String account;
  final String password;
  final Brightness theme;


  PasswordManagePage({Key key, this.account, this.password, this.theme})
      : super(key:key);

  @override
  _PasswordManagePageState createState() => _PasswordManagePageState();
}

class _PasswordManagePageState extends State<PasswordManagePage> {
  FocusNode _searchFocusNode = FocusNode();
  String _searchString = '';
  bool _needAddNewInfo = false;
  List<Widget> infoCards = List<Widget>();

  String _website='';
  // 账号匡焦点事件
  FocusNode _websiteFocusNode = FocusNode();
  // 账号匡控制器
  TextEditingController _websiteController = TextEditingController();
  // 用户密码
  String _userid='';
  // 密码匡焦点事件
  FocusNode _useridFocusNode = FocusNode();
  // 密码匡控制器
  TextEditingController _useridController = TextEditingController();

  // k-v 数据库
  bool kvInitFailed = false;
  PasswordInfoModelDao _passwordInfoModelDao;
  PasswordInfoModel _passwordInfoModel;

  @override
  void initState() {
    _searchFocusNode.addListener((){
      if(!_searchFocusNode.hasFocus) {
        if(_needAddNewInfo) {
          _websiteFocusNode.requestFocus();
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if(kvInitFailed){
      return ErrorPage();
    }

    if(_passwordInfoModelDao == null) {
      _readDataBase();
    }

    /*
    if( _searchString.length == 0 && infoCards.length == 0 ) {
      Future.delayed(Duration(milliseconds: 800)).then((_){
        if(_searchString.length == 0 && infoCards.length == 0){
          setState(() {
            _needAddNewInfo = true;
          });
        }
      });
    }
    */
    
    if(_needAddNewInfo) {
      _searchFocusNode.unfocus();
    }

    return Scaffold(
      floatingActionButton: _addNewPassword,
      body:GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: Column(
            children: <Widget>[
              _appBar,
              _needAddNewInfo ? _addBar : Container(),
              MediaQuery.removePadding(
                removeTop: true,
                  context: context,
                  child: Expanded(
                    flex: 1,
                    child: ListView(
                      children: infoCards,
                    ),
                  ),
              ),
            ],
          ),
        ),
    );
  }

  Widget get _appBar {
    return Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              //AppBar渐变遮罩背景
              colors: [Color(0x66000000), Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Container(
            padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
            height: 80.0,
            child: SearchBar(
              focusNode: _searchFocusNode,
                hint: '请输入app名称,域名或注册ID',
              leftButtonClick: () {
                Navigator.of(context).pop();
              },
              rightButtonClick: () {
                setState(() {
                  _searchFocusNode.unfocus();
                });
              },
              onChanged: _onSearch,
              ),
          ),
        ),
        Container(
            height: 0.5,
            decoration: BoxDecoration(
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 0.5)]))
      ],
    );
  }

  Widget get _addNewPassword {
    return  FloatingActionButton(
      onPressed: () {
        setState(() {
          _needAddNewInfo = !_needAddNewInfo;
        });
      },
      child: Icon( _needAddNewInfo ? Icons.arrow_downward : Icons.add),
    );
  }

  List<Widget> _mkPasswordInfo() {
    List<Widget> result = List<Widget>();
    InfoCard infoCard;
    _passwordInfoModel = _passwordInfoModelDao.fetch();
    if(_passwordInfoModelDao.noData) {
      /// 新账号, 没有数据, 写入初始化信息
      _passwordInfoModel = PasswordInfoModel(
        passwordInfo: Map<String, PasswordRecord>(),
      );
      _passwordInfoModelDao.write(_passwordInfoModel)
          .then((_){})
          .catchError((e){
            setState(() {
              kvInitFailed = true;
            });
      });
    } else if(_passwordInfoModel == null) {
      /// 解密出错了
      setState(() {
        kvInitFailed = true;
      });
    } else {
      /// 老账号, 解密正常
      if(_searchString.length == 0) {
        _passwordInfoModel.passwordInfo.forEach((k, v) {
          infoCard = InfoCard(
            onDelete: _onDelete,
            onAddIteration: _onAddIteration,
            websiteName: _passwordInfoModel.passwordInfo[k].websiteName,
            userID: _passwordInfoModel.passwordInfo[k].userID,
            password: _passwordInfoModel.passwordInfo[k].password,
            initExpand: false,
            iteration: _passwordInfoModel.passwordInfo[k].iteration,
            searchKeyword: _searchString??'',
          );
          result.add(infoCard);
        });
      } else {
        _passwordInfoModel.passwordInfo.forEach((k, v) {
          if(k.contains(_searchString)) {
            infoCard = InfoCard(
              onDelete: _onDelete,
              onAddIteration: _onAddIteration,
              websiteName: _passwordInfoModel.passwordInfo[k].websiteName,
              userID: _passwordInfoModel.passwordInfo[k].userID,
              password: _passwordInfoModel.passwordInfo[k].password,
              initExpand: false,
              iteration: _passwordInfoModel.passwordInfo[k].iteration,
              searchKeyword: _searchString??'',
            );
            result.add(infoCard);
          }
        });
      }
    }
    return result;
  }

  void _onDelete(String website, String userId) {
    String key = "$website.$userId";
    _passwordInfoModel.passwordInfo.remove(key);
    _writeDataBase();
  }

  void _onAddIteration(String website, String userId) {
    String key = "$website.$userId";
    int iteration = _passwordInfoModel.passwordInfo[key].iteration + 1;
    String websitePassword = _createPassword(iteration: iteration,
      account: widget.account, password: widget.password,
      website: website, userid: userId,);
    //_passwordInfoModel.passwordInfo.remove(key);
    _passwordInfoModel.passwordInfo[key].password = websitePassword;
    _passwordInfoModel.passwordInfo[key].iteration = iteration;
    /*
    _passwordInfoModel.passwordInfo[key] = PasswordRecord.fromJson(
        {"websiteName": website,
          "userID": userId,
          "password":websitePassword,
          "iteration":iteration, "comment":""}
    );
     */
    _writeDataBase();
  }

  Widget get _addBar {
    _websiteFocusNode.requestFocus();
    return Container(
      margin: EdgeInsets.only(bottom: 30),
      child: TowInputBar(
        getInputInfo: (website, userid){
          _website = website;
          _userid = userid;
          _summit();
        },
        upHint: "请输入app或网站信息",
        downHint: "请输入用户id",
        brightness: widget.theme,
        upAutoFocus: true,
        upFocusNode: _websiteFocusNode,
        upController: _websiteController,
        downFocusNode: _useridFocusNode,
        downController: _useridController,
        buttonTitle: "提交",
      ) ,
    );
  }

  void _summit() {
    if(_website == null || _website.length == 0) {
      return;
    }
    if(_userid == null || _website.length == 0) {
      return;
    }

    String key = "$_website.$_userid";
    if(_passwordInfoModel.passwordInfo.containsKey(key)) {
      _websiteController.clear();
      _useridController.clear();
      return;
    }

    _websiteController.clear();
    _useridController.clear();
    String websitePassword = _createPassword(iteration: 1,
      account: widget.account, password: widget.password,
      website: _website, userid: _userid,);
    /*
     * {'websiteName': 'website_name', 'userID' : 'use_id',
     *        'password':'password', 'iteration': '123',
     *        'comment' : 'comment'},
     */
    _passwordInfoModel.passwordInfo[key] = PasswordRecord.fromJson(
        {"websiteName": _website,
          "userID": _userid,
          "password":websitePassword,
          "iteration":1, "comment":""}
        );
    _writeDataBase();
    setState(() {
      _needAddNewInfo = false;
    });
  }

  String _createPassword({int iteration = 1, @required String account,
      @required String password, @required String website,
      @required String userid}) {
    String passwordBase = "$account$website$password$userid";
    Uint8List uint8list;
    Uint8List uint8listCanPrint;
    String str;
    if(iteration < 1) {
      iteration = 1;
    }
    while(iteration > 0) {
      uint8list = md5.convert(utf8.encode(passwordBase)).bytes;
      uint8listCanPrint = Uint8List(uint8list.length);
      for(int i = 0; i < uint8list.length; i++) {
        /*
         * 密码字符串过滤 去除非法字符和不可打印字符
         */
        int val = uint8list[i] & 0x7f;
        if( val < 0x21 ) {
          val += 0x21;
        }
        if(val >= 0x7f){
          val = 0x7e;
        }
        if( val == 0x22 ) {
          val = 0x61;
        }
        if( val == 0x27 ) {
          val = 0x62;
        }
        if( 0x2b <= val && val <= 0x2f) {
          val += 5;
        }
        if( 0x3a <= val && val <= 0x3f) {
          val += 6;
        }
        if( 0x5b <= val && val <= 0x60) {
          val -= 8;
        }
        if( 0x7b <= val && val <= 0x7f) {
          val -= 10;
        }
        uint8listCanPrint[i] = val;
      }
      passwordBase = ascii.decode(uint8listCanPrint);
      iteration--;
    }

     str = ascii.decode(uint8listCanPrint);

    return str;
  }

  void _writeDataBase() {
    _passwordInfoModelDao.write(_passwordInfoModel).then((result){
      if(result == false){
        setState(() {
          kvInitFailed = false;
        });
        return;
      }
      setState(() {
        _passwordInfoModelDao = null;
      });
    }).catchError((e){
      setState(() {
        kvInitFailed = false;
      });
    });
  }
  void _readDataBase() async {
    SharedPreferences.getInstance().then((prefs){
      _passwordInfoModelDao = PasswordInfoModelDao(
        prefs: prefs,
        userName: widget.account,
        password: widget.password,
      );
      setState(() {
        infoCards = _mkPasswordInfo();
        if(_searchString.length == 0 && infoCards.length == 0){
          setState(() {
            _needAddNewInfo = true;
          });
        }
      });
    }).catchError((e){
      setState(() {
        kvInitFailed = true;
      });
    });
  }

  void _onSearch(String text) {
    setState(() {
      _searchString = text;
      if(_searchString.length > 0) {
        _needAddNewInfo = false;
      }
      _passwordInfoModelDao = null;
    });
  }
}
