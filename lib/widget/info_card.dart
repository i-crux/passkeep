import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class InfoCard extends StatefulWidget {

  // websiteName userID
  final Function(String, String) onDelete;
  final Function(String, String) onAddIteration;
  final String websiteName;
  final String userID;
  final String password;
  final int iteration;
  final String comment;
  final bool initExpand;
  final String searchKeyword;

  const InfoCard({Key key, this.onDelete, this.onAddIteration,
    this.websiteName, this.userID, this.password, this.iteration,
    this.comment = '', this.initExpand = false, this.searchKeyword = ''})
      : assert(searchKeyword != null), super(key: key);


  @override
  _InfoCardState createState() => _InfoCardState();
}

class _InfoCardState extends State<InfoCard> {
  bool isExpand;
  bool initialed = false;
  @override
  Widget build(BuildContext context) {
    if(initialed == false) {
      isExpand = widget.initExpand;
      initialed = true;
    }
    return Container(
      margin: EdgeInsets.fromLTRB(10, 5, 10, 0),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ExpansionTile(
        initiallyExpanded: widget.initExpand,
        onExpansionChanged: (val){
          setState(() {
            isExpand = val;
          });
        },
        leading: Icon( isExpand == true ?
          Icons.keyboard_arrow_up : Icons.keyboard_arrow_down ),
        trailing: _deleteButton,
        title: _title,
        children: <Widget>[
          Divider(
            thickness:2,
            color: Colors.deepOrange,
          ),
          _infoContainer(widget.userID),
          Divider(),
          _infoContainer(widget.password, height: 50, iterationButton: _iterationButton),
        ],
      ),
    );
  }

  Widget get _title {
    return Center(
      child: _mkTitle(widget.websiteName, widget.userID, widget.searchKeyword),
    );
  }

  Widget get _deleteButton {
    return IconButton(
        icon: Icon(Icons.delete),
        onPressed: () {
          Future.delayed(Duration(milliseconds: 50)).then((_) {
            if(widget.onDelete != null) {
              widget.onDelete(widget.websiteName, widget.userID);
            }
          });
        });
  }

  Widget _copyIcon (String text) {
    return IconButton(
        icon:  Icon(
          Icons.content_copy,
          size: 18,
        ),
        onPressed: () {
          Clipboard.setData(new ClipboardData(text: text));
        });
  }

  Widget _infoContainer(String text, {Widget iterationButton, double height = 40}) {
    return Container(
      height: height,
      margin: EdgeInsets.only(left: 20, right: 10, bottom: 5, top: 0),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Text(
              text,
              style: TextStyle(
                  fontSize: 18,
                color: Colors.white54,
              ),
            ),
          ),
          _copyIcon(text),
          iterationButton != null ? iterationButton : Container(),
        ],
      ),
    );
  }

  Widget get _iterationButton {
    return Row(
      children: <Widget>[
        IconButton(
          icon:  Icon(
            Icons.add,
            size: 18,
          ),
          onPressed: () {
            if(widget.onAddIteration != null) {
              widget.onAddIteration(widget.websiteName, widget.userID);
          }
        }),
        Text(widget.iteration.toString()),
      ],
    );
  }

  Widget _mkTitle(String websiteName, String userID, String searchKeyword) {
    String title = "${widget.websiteName}  ${widget.userID}";


    RichText richText;
    richText = RichText(
      text: TextSpan(
        children: _keywordTextSpans(title, searchKeyword),
      ),
    );
    return richText;
  }

  List<TextSpan> _keywordTextSpans(String word, String keyword) {
    List<TextSpan> spans = [];
    if (word == null || word.length == 0) return spans;
    //搜索关键字高亮忽略大小写
    String wordL = word.toLowerCase(), keywordL = keyword.toLowerCase();
    List<String> arr = wordL.split(keywordL);
    TextStyle normalStyle = TextStyle(fontSize: 15, color: Colors.white70,
        fontWeight: FontWeight.w500);
    TextStyle keywordStyle = TextStyle(fontSize: 16, color: Colors.orange,
        fontWeight: FontWeight.w700);
    //'wordwoc'.split('w') -> [, ord, oc] @https://www.tutorialspoint.com/tpcg.php?p=wcpcUA
    int preIndex = 0;
    for (int i = 0; i < arr.length; i++) {
      if (i != 0) {
        //搜索关键字高亮忽略大小写
        preIndex = wordL.indexOf(keywordL, preIndex);
        spans.add(TextSpan(
            text: word.substring(preIndex, preIndex + keyword.length),
            style: keywordStyle));
      }
      String val = arr[i];
      if (val != null && val.length > 0) {
        spans.add(TextSpan(text: val, style: normalStyle));
      }
    }
    return spans;
  }
}
