import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class Content extends StatelessWidget {
  final String content;

  Content({Key key, this.content}) : super(key: key);

  void onTap(String url, BuildContext context) async {
    CustomTabsOption option = CustomTabsOption(
      toolbarColor: Theme.of(context).primaryColor,
      enableDefaultShare: true,
      enableUrlBarHiding: true,
      showPageTitle: true,
      animation: new CustomTabsAnimation.slideIn(),
    );
    await launch(url, option: option);
  }

//  void formatter() {
//    RegExp urlExp = RegExp(
//        r'(http\:\/\/www\.|https\:\/\/www\.|http\:\/\/|https\:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(\:[0-9]{1,5})?(\/.*)?');
//    formattedString.insert(
//        0,
//        content.replaceAllMapped(urlExp, (Match match) {
//          var data = match.group(0);
//          var lastChar = data.substring(data.length - 1, data.length) == "]";
//          if (lastChar.toString() != "]") {
//            return "[$data]";
//          } else {
//            return data;
//          }
//        }));
//  }

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
      data: content,
      onTapLink: (String url) => onTap(url, context),
    );
  }
}
