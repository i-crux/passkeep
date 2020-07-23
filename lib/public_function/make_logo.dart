import 'package:flutter/cupertino.dart';

Widget makeLogo() {
  return  Container(
    margin: EdgeInsets.only(top: 20),
    child: Image.asset(
      'images/applogo.png',
      height: 85,
      width: 85,
    ),
  );
}

Brightness getSystemThemeSetting(BuildContext context) {
  return MediaQuery.platformBrightnessOf(context);
}