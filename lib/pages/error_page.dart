import 'package:flutter/material.dart';
import 'package:passkeep/public_function/make_logo.dart';

class ErrorPage extends StatelessWidget {
  static const Brightness _appSelectedTheme = Brightness.dark;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0, //去掉Appbar底部阴影
      ),
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            _logo,
            Container (
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(left:30, top: 80),
              child: Text(
                "如果你看到这个页面,\n"
                    "则说明本APP出现了严重的错误,\n"
                    "此错误一般由文件I/O引起.\n"
                    "请通过此github地址与作者联系:\n"
                    "   https://github.com/xxx/xxx",
                style: TextStyle(
                  fontSize: 20,
                  color: _appSelectedTheme == Brightness.dark ?
                  Colors.deepOrange : Colors.deepOrange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget get _logo {
    return makeLogo();
  }
}