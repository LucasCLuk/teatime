import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:flutter_list_drag_and_drop/drag_and_drop_list.dart';
import 'package:teatime/items/general/general.dart';
import 'package:teatime/items/subreddit/tile.dart';
import 'package:teatime/utils/redditBloc.dart';
import 'package:teatime/utils/redditViewModel.dart';

class SubscriptionWidget extends StatefulWidget {
  @override
  _SubscriptionWidgetState createState() => _SubscriptionWidgetState();
}

class _SubscriptionWidgetState extends State<SubscriptionWidget>
    with RouteAware {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  RedditBloc redditState;

  void unSubscribe(BuildContext context, Subreddit subreddit, int index) async {
    await redditState.currentAccount.unsubscribe(subreddit);
    setState(() {});
    _scaffoldKey.currentState.showSnackBar(undoUnsub(subreddit, index));
  }

  void subscribeToSubreddit() async {
    Subreddit sub;
    await showDialog<Subreddit>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Go To Subreddit"),
            content: SearchSubredditWidget(
              onFind: (subreddit) {
                sub = subreddit;
              },
            ),
            actions: <Widget>[
              FlatButton(
                  onPressed: () => Navigator.of(context).pop(sub),
                  child: Text("Confim"))
            ],
          );
        }).then((Subreddit subreddit) async {
      if (subreddit != null) {
        try {
          await redditState.changeSubreddit(context,subreddit);
        } catch (e) {
//          Fluttertoast.showToast(
//              msg: "Subreddit not found",
//              toastLength: Toast.LENGTH_SHORT,
//              textcolor: '#ffffff');
        }
      }
    });
    if (sub != null) {
      await redditState.currentAccount.subscribe(sub);
    }
    setState(() {});
  }

  void refreshSubreddits() async {
    redditState.currentAccount
        .refreshSubscriptions()
        .then((_) => Navigator.of(context).pop(true), onError: (_) {
      print(_);
      Navigator.pop(context, false);
    });
    var isRefreshed = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Row(
              children: <Widget>[
                CircularProgressIndicator(),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Text("Refreshing"),
                )
              ],
            ),
          );
        });
    if (isRefreshed) {
      setState(() {});
    } else {
      _scaffoldKey.currentState.showSnackBar(
          SnackBar(content: Text("Unable to refresh subreddits")));
    }
  }

  void sortAlpha() async {
    redditState.currentAccount.subscriptionOrder
        .sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    await redditState.currentAccount.saveSubscriptions();
    setState(() {});
  }

  SnackBar undoUnsub(Subreddit subreddit, int index) {
    return SnackBar(
        content: Text("Sucessfully unsubscribed"),
        action: SnackBarAction(
            label: "Undo",
            onPressed: () async {
              await subreddit.subscribe();
              redditState.currentAccount.subscriptionOrder
                  .insert(index, subreddit.displayName);
              redditState.currentAccount.subscriptions[subreddit.displayName] =
                  subreddit;
              setState(() {});
            }));
  }

  void changeIndex(int before, int after) async {
    var item = redditState.currentAccount.subscriptionOrder.removeAt(before);
    redditState.currentAccount.subscriptionOrder.insert(after, item);
    await redditState.currentAccount.saveSubscriptions();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    redditState = RedditProvider.of(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text("Subscriptions"),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.sort_by_alpha), onPressed: sortAlpha),
          IconButton(icon: Icon(Icons.refresh), onPressed: refreshSubreddits),
        ],
      ),
      body: new Scrollbar(
          child: new DragAndDropList<String>(
              redditState.currentAccount.subscriptionOrder,
              onDragFinish: changeIndex,
              itemBuilder: (BuildContext context, dynamic item, int index) {
                Subreddit subreddit =
                redditState.currentAccount.subscriptions[item];
                if (subreddit != null) {
                  return SubredditTile(
                    subreddit: subreddit,
                    trailing: IconButton(
                        tooltip: "Unsubscribe",
                        icon: Icon(Icons.cancel),
                        onPressed: () {
                          unSubscribe(context, subreddit, index);
                        }),
                  );
                } else {
                  return Container(
                    width: 0.0,
                    height: 0.0,
                  );
                }
              },
              canBeDraggedTo: (one, two) => true)),
      floatingActionButton: FloatingActionButton(
        onPressed: subscribeToSubreddit,
        child: Icon(Icons.add),
      ),
    );
  }
}
