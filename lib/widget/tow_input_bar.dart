import 'package:flutter/material.dart';

enum InputFieldType {normal, secret}

class TowInputBar extends StatefulWidget {
  /// 获取输入匡信息的函数
  final void Function(String, String) getInputInfo;
  /// 主题色
  final Brightness brightness;
  /// 上部输入框使用
  // 上部输入框类型
  final InputFieldType upType;
  // 上部匡焦点事件
  final FocusNode upFocusNode;
  // 上部输入框控制器
  final TextEditingController upController;
  // 上部输入框icon
  final IconData upIcon;
  // 上部输入框title
  final String upTitle;
  // 上部输入框提示
  final String upHint;
  final bool upAutoFocus;
  /// 下部输入框使用
  // 下部输入框类型
  final InputFieldType downType;
  // 下部输入匡焦点事件
  final FocusNode downFocusNode;
  // 下部输入框控制器
  final TextEditingController downController;
  // 上部输入框icon
  final IconData downIcon;
  // 下部输入框title
  final String downTitle;
  // 下部输入匡提示
  final String downHint;
  final bool downAutoFocus;
  /// 按钮title
  final String buttonTitle;
  /// 长按按钮的动作
  final void Function(String, String) longPress;


  TowInputBar({Key key, this.getInputInfo, this.brightness,
    this.upType = InputFieldType.normal, this.upFocusNode,
    this.upController, this.upIcon = Icons.person,
    this.upTitle='', this.upHint='', this.upAutoFocus = false,
    this.downType = InputFieldType.normal, this.downFocusNode,
    this.downController, this.downIcon = Icons.lock,
    this.downTitle='', this.downHint='', this.downAutoFocus = false,
    this.buttonTitle='', this.longPress}) : super(key: key);

  @override
  _TowInputBarState createState() => _TowInputBarState();
}

class _TowInputBarState extends State<TowInputBar> {

  // 用户账号
  String _upString;
  // 用户密码
  String _downString;

  // 上输入框是否隐藏输入
  IsHideText upHideInput;
  // 下输入框是否隐藏输入
  IsHideText downHideInput;

  @override
  Widget build(BuildContext context) {
    upHideInput = (widget.upType == InputFieldType.normal ?
      IsHideText(false) : IsHideText(true));
    downHideInput = (widget.downType == InputFieldType.normal ?
      IsHideText(false) : IsHideText(true));

    return Column(
      children: <Widget>[
        /// 上title
        Container(
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.only(left:50),
          child: _inputTitle(widget.upTitle),
        ),
        /// 上输入筐
        Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(left:50, top: 0, right: 50),
            child: _inputField(widget.upType, widget.upFocusNode,
                widget.upController, widget.upAutoFocus, widget.upIcon,
                widget.upHint, widget.downFocusNode),
        ),
        /// 下title
        Container(
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.only(
              left:50,
              top: widget.downTitle != null && widget.downTitle.length > 0 ?
              20 : 0),
          child: _inputTitle(widget.downTitle)
        ),
        /// 下输入框
        Container(
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.only(left:50, top: 0, right: 50),
          child: _inputField(widget.downType, widget.downFocusNode,
              widget.downController, widget.downAutoFocus, widget.downIcon,
              widget.downHint, null),
        ),
        _button(widget.buttonTitle),
      ],
    );
  }

  Widget _button (String hint){
    return widget.buttonTitle != null && widget.buttonTitle.length > 0 ?
      Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(left:70, top: 20, right: 70),
        child: GestureDetector(
          onTap: widget.getInputInfo != null ? () {
            widget.getInputInfo(_upString, _downString);
          } : null,
          onLongPress: widget.longPress != null ? () {
            widget.longPress(_upString, _downString);
          } : null,
          child: Container(
            decoration: BoxDecoration(
              color: widget.brightness == Brightness.light ?
              Colors.black : Colors.black38,
            ),
            alignment: Alignment.center,
            height: 35,
            child: Text(
              hint,
              style: TextStyle(
                fontSize: 20,
                color: widget.brightness == Brightness.light ?
                Colors.white : Colors.white60,
              ),
            ),
          ),
        )
    ) : Container();
  }

  Widget _inputTitle(String title) {
    return title != null && title.length > 0 ? Text(
      title,
      style: TextStyle(
        fontFamily: 'simhei',
        fontSize: 18,
        fontWeight: FontWeight.w300,
        color: widget.brightness == Brightness.light ?
        Colors.black : Colors.white60,
      ),
    ) : null;
  }

  Widget _inputField(InputFieldType inputType,  FocusNode myFocusNode,
      TextEditingController textEditingController, bool autoFocus,
      IconData icon, String hint, FocusNode nextFocusNode) {
    return TextField(
      autofocus: autoFocus,
      focusNode: myFocusNode,
      controller: textEditingController,
      obscureText: inputType == InputFieldType.normal ? false : true,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hint,
        hintStyle: TextStyle(fontSize: 12,
            fontStyle: FontStyle.italic),
        suffixIcon: (textEditingController.text != null 
            && textEditingController.text.length > 0) ?
          _normalSuffixButton(textEditingController) : null,
      ),
      onChanged: nextFocusNode != null ? _onChangedUp : _onChangedDown,
      onEditingComplete: () {
        myFocusNode.unfocus();
        nextFocusNode?.requestFocus();
        if(nextFocusNode == null)
          widget.getInputInfo(_upString, _downString);
      },
    );
  }

  void _onChangedUp(String text) {
    setState(() {
      _upString = text.trim();
    });
    // print('upString: $_upString');
  }
  void _onChangedDown(String text) {
    setState(() {
      _downString = text.trim();
    });
    // print("_downString: $_downString");
  }

  Widget _normalSuffixButton(TextEditingController controller) {
    return IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          //focusNode.requestFocus();
          Future.delayed(Duration(milliseconds: 50)).then((_) {
            setState(() {
              controller.text='';
            });
            //focusNode.unfocus();
          });

        });
  }

}


class IsHideText {
  bool isHide;
  IsHideText(this.isHide);
}

class UserInfo {
  final String userName;
  final String password;

  UserInfo(this.userName, this.password);
}
