import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:teatime/items/general/general.dart';
import 'package:teatime/items/post/content.dart';
import 'package:teatime/utils/enums.dart';
import 'package:timeago/timeago.dart' as timeago;

enum MessageType { CommentReply, PM, PostReply, Sent, Mention }

class MessageWidget extends StatefulWidget {
  final MessageType messageType;
  final dynamic message;

  const MessageWidget({Key key, this.messageType, @required this.message})
      : super(key: key);

  @override
  _MessageState createState() => _MessageState();
}

class _MessageState extends State<MessageWidget> {
  Map<String, Map<String, dynamic>> alertOptions = {};

  Icon getIcon() {
    switch (widget.message.runtimeType) {
      case Message:
        return Icon(Icons.message);
        break;
      case Comment:
        return Icon(Icons.comment);
        break;
      default:
        return Icon(Icons.question_answer);
        break;
    }
  }

  List<InkWell> buildAlertOptions() {


    if (widget.message is Message) {
      var message = (widget.message as Message);
      dynamic destination;
      alertOptions["Reply"] = {"icon": Icon(Icons.reply), "func": () async  {
        if (message.wasComment){
          try {
            destination = await message.reddit.subreddit(message.destination).populate();
          } catch (e) {
            try {
              destination = await message.reddit.redditor(message.destination).populate();
            } catch (e) {
            }
          }
          if (destination is Subreddit){
            
          }
        }
      }};
      alertOptions["Mark as unread"] = {
        "icon": Icon(Icons.reply),
        "func": () => message.markUnread()
      };
      if (widget.message.author != null) {
        alertOptions["About ${message.destination}"] = {
          "icon": Icon(Icons.account_circle),
          "func": () => Navigator.pushNamed(
              context, "/u/${widget.message.author?.displayName}")
        };

        alertOptions["Block ${message.destination}"] = {
          "icon": Icon(Icons.block),
          "func": () => (widget.message as Message).block()
        };
      }
    }

    if (widget.message.subreddit?.displayName != null) {
      alertOptions["Go to ${widget.message.subreddit.displayName}"] = {
        "icon": Icon(Icons.redo),
        "func": () {
          Navigator.of(context)
              .pushNamed("/r/${widget.message.subreddit.displayName}");
        }
      };
    }
    List<InkWell> options = [];
    alertOptions.forEach((String key, dynamic value) {
      options.add(new InkWell(
        onTap: value['func'],
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: <Widget>[
              value['icon'],
              Padding(
                padding: EdgeInsets.only(left: 15.0),
                child: Text(key),
              ),
            ],
          ),
        ),
      ));
    });
    return options;
  }

  void buildAlert() {
    showDialog(
        context: context,
        builder: (context) => SimpleDialog(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: new Column(children: buildAlertOptions()),
                )
              ],
            ));
  }

  Widget buildLabel() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        getIcon(),
        Text("Comment Reply"),
        Expanded(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            IconButton(icon: Icon(Icons.more_vert), onPressed: buildAlert)
          ],
        ))
      ],
    );
  }

  Widget buildCommentReply() {
    return new Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Text("From"),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: LinkAble(
              targetType: TargetType.User,
              targetString: widget.message?.author),
        ),
        Text(timeago.format(widget.message.createdUtc, locale: "en_short"))
      ],
    );
  }

  Widget buildMessageReply() {
    return new Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Text("From"),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: LinkAble(
              targetType: TargetType.User,
              targetString: widget.message?.author),
        ),
        Text(timeago.format(widget.message.createdUtc, locale: "en_short"))
      ],
    );
  }

  Widget buildRow() {
    switch (widget.message.runtimeType) {
      case Message:
        return buildMessageReply();
      case Comment:
        return buildCommentReply();
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          buildLabel(),
          Container(
            child: widget.message.runtimeType == Comment &&
                    widget.message.subreddit != null
                ? LinkAble(
                    target: widget.message.subreddit,
                    targetString: widget.message.subreddit?.displayName,
                    targetType: TargetType.Subreddit,
                  )
                : null,
          ),
          buildRow(),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
            child: Content(content: widget.message.body),
          ),
          new Divider()
        ],
      ),
    );
  }
}
