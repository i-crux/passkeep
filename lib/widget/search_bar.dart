import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  final FocusNode focusNode;
  final String hint;
  final void Function() leftButtonClick;
  final void Function() rightButtonClick;
  final ValueChanged<String> onChanged;

  const SearchBar({Key key, @required this.focusNode, this.hint,
        this.leftButtonClick, this.rightButtonClick, this.onChanged})
      : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  bool showClear = false;
  final TextEditingController _controller = TextEditingController();


  @override
  void initState() {
    widget.focusNode.addListener((){
      setState(() {

      });
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return _genSearchBar();
  }

  Widget _genSearchBar() {
    return Container(
      child: Row(children: <Widget>[
        _wrapTap(
            Container(
              padding: EdgeInsets.fromLTRB(6, 5, 10, 5),
              child: Icon(
                Icons.arrow_back_ios,
                color: Colors.grey,
                size: 26,
              ),
            ),
            widget.leftButtonClick),
        Expanded(
          flex: 1,
          child: _inputBox(),
        ),
        _wrapTap(
            Container(
              padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: Text(
                widget.focusNode.hasFocus? '完成': '     ',
                style: TextStyle(color: Colors.blue, fontSize: 15),
              ),
            ),
            widget.rightButtonClick)
      ]),
    );
  }

  Widget _inputBox() {
    Color inputBoxColor = Color(int.parse('0xffEDEDED'));

    return Container(
      height: 30,
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      decoration: BoxDecoration(
          color: inputBoxColor,
          borderRadius: BorderRadius.circular(
              widget.focusNode.hasFocus ? 5 : 15),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.search,
            size: 20,
            color: Color(0xffA9A9A9),
          ),
          Expanded(
              flex: 1,
              child: TextField(
                  controller: _controller,
                  focusNode: widget.focusNode,
                  onChanged: _onChanged,
                  //autofocus: true,
                  style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.black,
                      fontWeight: FontWeight.w300),
                  //输入文本的样式
                  decoration: InputDecoration(
                    contentPadding:
                    //flutter sdk >= v1.12.1 输入框样式适配
                    EdgeInsets.only(left: 5, bottom: 12, right: 5),
                    border: InputBorder.none,
                    hintText: widget.hint ?? ' ',
                    hintStyle: TextStyle(
                        fontSize: 15,
                      color: Colors.grey,
                    ),
                  ))
          ),
          !showClear
              ? Container()
              : _wrapTap(
              Icon(
                Icons.clear,
                size: 22,
                color: Colors.grey,
              ), () {
            setState(() {
              _controller.clear();
            });
            _onChanged('');
          })
        ],
      ),
    );
  }

  Widget _wrapTap(Widget child, void Function() callback) {
    return GestureDetector(
      onTap: () {
        if (callback != null) callback();
      },
      child: child,
    );
  }

  void _onChanged(String text) {
    if (text.length > 0) {
      if(showClear == false) {
        setState(() {
          showClear = true;
        });
      }
    } else {
      if(showClear == true) {
        setState(() {
          showClear = false;
        });
      }
    }
    if (widget.onChanged != null) {
      /// 这里是为了把字符变化传出去
      widget.onChanged(text);
    }
  }
}