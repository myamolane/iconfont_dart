import 'dart:io';
import 'package:html/parser.dart' show parse;

String _dir = './assets/fonts/demo_index.html'; // iconfont中 demo_index.html目录
String _buildDir = './index.dart'; // 生成文件路径

void main() {
  IconfontDart();
}

class IconfontDart {

  IconfontDart() {
    List fontClassName;
    List unicode;
    // 读取demo_index.html 获取unicode
    File(_dir).readAsString()
      .then((onValue){
        var doc = parse(onValue);
        var div = doc.getElementsByClassName('content');
        // 遍历获取 unicode || classname
        div.forEach((val) {
          // font-class
          if(val.className.indexOf('font-class') > -1) {
            var li = getLi(val);
            fontClassName = getSpan(li, type: 'classname');
          }

          // unicode dom
          if(val.className.indexOf('unicode') > -1) {
            var li = getLi(val);
            unicode = getSpan(li, type: 'unicode');
          }
        });
        writeIcon(fontClassName, unicode);
      });
  }
  // 写入文件
  writeIcon(List classname, List unicode) {
    String str = "";

    classname.asMap().forEach((index, val){
      str = '$str${formatIcon(val, unicode[index])}';
    });

    File(_buildDir).writeAsString("import 'package:flutter/material.dart';\n\n$str");

  }

  // 格式化icon代码
  formatIcon(classname, unicode) {
    return  """Icon $classname() => Icon(
    IconData($unicode, fontFamily: 'iconfont'),
    size: 18,
  );\n\n""";  
  }

  /// 获取 unicode || classname
  /// @type  classname || unicode
  getSpan(doc, {String type}) {
    List<String> arr = List<String>();
    doc.forEach((val) {
      var div = val.getElementsByClassName('code-name')[0];
      var str = div.innerHtml.toString();
      if(type == 'classname') { // classname
        arr.add(str.replaceAll(new RegExp('\\.|\\n|\\s|\\-'), ''));
      } else { // unicode
        arr.add('0${str.split('#')[1].replaceAll(';', '')}');
      }
    });

    return arr;
  }

  // 获取li
  getLi(doc) {
    var ul = doc.getElementsByClassName('icon_lists')[0];
    var li = ul.getElementsByTagName('li');

    return li;
  }
}
