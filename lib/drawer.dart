import 'package:draw/draw.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:teatime/items/general/linkable.dart';
import 'package:teatime/items/general/subreddit_search.dart';
import 'package:teatime/items/profile/profile.dart';
import 'package:teatime/items/subreddit/icon_builder.dart';
import 'package:teatime/utils/enums.dart';
import 'package:teatime/utils/redditBloc.dart';
import 'package:teatime/utils/redditViewModel.dart';
//import 'package:fluttertoast/fluttertoast.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({Key key}) : super(key: key);

  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  RedditBloc redditState;
  bool isExpanded = false;

  void setFrontPage() {
    Navigator.popUntil(context, ModalRoute.withName("/"));
    redditState.changeSubreddit(context, null);
  }

  void setPosition(BottomScreens newScreen, {bool pop = true}) {
    if (pop) Navigator.of(context).pop();
    redditState.currentPosition = newScreen;
  }

  void openSubscriptions() {
    Navigator.pushNamed(context, "/subscriptions");
  }

  void setTheme(bool newPosition) {
    setState(() {
      redditState.preferences.appTheme =
          newPosition ? AppThemes.dark : AppThemes.light;
    });
  }

  void filterNSFW(bool newPosition) {
    setState(() {
      redditState.preferences.filterNSFW = !newPosition;
    });
  }

  Widget buildItem(Icon icon, Text label,
      [Function onTap, bool pop = false, bool isEnabled = true]) {
    return new ListTile(
      leading: icon,
      title: label,
      enabled: isEnabled,
      onTap: onTap != null
          ? () {
              if (pop) {
                Navigator.of(context).pop();
              }
              onTap();
            }
          : null,
    );
  }

  void goToSubreddit() async {
    Subreddit sub;
    showDialog<Subreddit>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Go To Subreddit"),
            content: Scrollable(
              viewportBuilder: (BuildContext context, ViewportOffset position) {
                return SearchSubredditWidget(
                  onFind: (subreddit) {
                    sub = subreddit;
                  },
                );
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
          await redditState.changeSubreddit(context, subreddit);
        } catch (e) {
//          Fluttertoast.showToast(
//              msg: "Subreddit not found",
//              toastLength: Toast.LENGTH_SHORT,
//              textcolor: '#ffffff');
        }
      }
    });
  }

  void goToUser() async {
    showDialog<String>(
        context: context,
        builder: (context) {
          var _textController = TextEditingController();
          return AlertDialog(
            title: Text("Go To User"),
            content: TextField(
              autofocus: true,
              autocorrect: true,
              controller: _textController,
            ),
            actions: <Widget>[
              FlatButton(
                  onPressed: () =>
                      Navigator.of(context).pop(_textController.text),
                  child: Text("Confim"))
            ],
          );
        }).then((String user) async {
      if (user != null) {
        try {
          await Navigator.popAndPushNamed(context, "/users/$user");
        } catch (e) {
//          Fluttertoast.showToast(
//              msg: "Subreddit not found",
//              toastLength: Toast.LENGTH_SHORT,
//              textcolor: '#ffffff');
        }
      }
    });
  }

  Widget buildToggleItem(Icon icon, Text label,
      {Function(bool newValue) onTap, bool pop, bool isChecked}) {
    return ListTile(
      leading: icon,
      title: label,
      trailing: Switch(
        value: isChecked,
        onChanged: onTap,
      ),
    );
  }

  Widget buildGoTo() {
    return new ExpansionTile(
      title: Text("Go to..."),
      children: <Widget>[
        buildItem(null, Text("Subreddit"), goToSubreddit),
//        buildItem(null, Text("User"), goToUser),
//        buildItem(null, Text("Random"),
//            () async => await redditState.getRandomSubreddit(context)),
//        buildItem(null, Text("Random NSFW")),
      ],
    );
  }

  List<Widget> buildMenu() {
    return [
      buildItem(Icon(Icons.home), Text("Home"),
          () => setPosition(BottomScreens.home)),
      buildItem(Icon(Icons.flip_to_front), Text("Front Page"), setFrontPage),
      buildItem(Icon(Icons.call_made), Text("Popular"),
          () => redditState.changeSubreddit(context, "popular"), true),
      buildItem(Icon(Icons.equalizer), Text("All"),
          () => redditState.changeSubreddit(context, "all"), true),
      buildItem(
          Icon(Icons.star),
          Text("Saved"),
          redditState.isLoggedIn
              ? () => redditState.changeSubreddit(
                  context, "${redditState.currentAccount.redditor.path}saved")
              : null,
          true,
          redditState.isLoggedIn),
      Divider(),
      buildItem(
          Icon(Icons.account_circle),
          Text("Profile"),
          () => setPosition(BottomScreens.profile),
          false,
          redditState.isLoggedIn),
      buildItem(
          Icon(Icons.email),
          Text("Inbox"),
          () => setPosition(BottomScreens.inbox),
          false,
          redditState.isLoggedIn),
      buildItem(
          Icon(Icons.group),
          Text("Friends"),
          () => Navigator.pushNamed(context, "/friends"),
          true,
          redditState.isLoggedIn),
      Divider(),
      buildGoTo(),
      buildItem(Icon(Icons.subscriptions), Text("Subscriptions"),
          openSubscriptions, false, redditState.isLoggedIn),
      buildItem(
          Icon(Icons.history),
          Text("History"),
          redditState.preferences.isTracking
              ? () => Navigator.pushNamed(context, "/history")
              : null,
          true,
          redditState.preferences.isTracking),
      buildToggleItem(Icon(Icons.lightbulb_outline), Text("Night Mode"),
          onTap: setTheme, isChecked: redditState.preferences.nightTheme),
      buildToggleItem(Icon(Icons.tag_faces), Text("Show NSFW"),
          onTap: filterNSFW, isChecked: !redditState.preferences.filterNSFW),
      buildItem(Icon(Icons.settings), Text("Settings"),
          () => Navigator.of(context).pushNamed("/settings")),
    ];
  }

  ListView buildNonCompactNormal() {
    final menu = buildMenu();
    menu.insert(0, buildHeader());
    menu.add(Divider());
    menu.add(Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text("Subscriptions"),
    ));
    if (redditState.isLoggedIn) {
      redditState.currentAccount.subscriptionOrder.forEach((String sub) {
        Subreddit subreddit = redditState.currentAccount.subscriptions[sub];
        if (subreddit != null) {
          final menuItem = new Container(
            width: double.infinity,
            height: 50.0,
            child: new LinkAble(
              targetType: TargetType.Subreddit,
              target: subreddit,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 20.0),
                child: Text(
                  subreddit.displayName,
                  style: Theme.of(context).textTheme.body1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
          menu.add(menuItem);
        }
      });
    }
    return ListView(children: menu);
  }

  List<Widget> buildAccounts() {
    return redditState.preferences.linkedAccountNames.map((String accountName) {
      ListTile(
        leading: Icon(Icons.account_circle),
        title: Text(accountName),
        trailing: IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () async {
              await redditState.removeAccount(accountName);
            }),
        onTap: () async {
          Navigator.of(context).popUntil(ModalRoute.withName("/"));
          await redditState.switchAccount(accountName);
        },
      );
    }).toList();
  }

  ListView buildNonCompactExpanded() {
    List<Widget> accountList = buildAccounts();
    return ListView(
        children: <Widget>[
      buildHeader(),
    ]
          ..addAll(accountList)
          ..addAll([
            buildItem(Icon(Icons.add), Text("Add new Account"), () async {
              await redditState.login(context);
              setState(() {});
            }, true),
            Divider(),
            redditState.isLoggedIn
                ? buildItem(Icon(Icons.cancel), Text("Sign out"), () async {
                    await redditState.logout();
                  }, true)
                : Container(
                    width: 0.0,
                    height: 0.0,
                  )
          ]));
  }

  Widget buildHeader() {
    return new UserAccountsDrawerHeader(
      currentAccountPicture: InkWell(
        onTap: () async {
          if (redditState.isLoggedIn) {
            Navigator.pop(context);
            redditState.currentPosition = BottomScreens.profile;
          } else {
            await redditState.login(context);
          }
        },
        child: ProfileIcon(
          iconURL: redditState.isLoggedIn == true
              ? redditState.currentAccount.redditor.data['icon_img']
              : null,
        ),
      ),
      accountName: Center(
          child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Text(
            redditState?.currentAccount?.redditor?.displayName ?? "Anonymous"),
      )),
      accountEmail: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text(redditState?.currentAccount?.redditor?.linkKarma?.toString() ??
              "0"),
          Icon(Icons.link),
          Text(
              redditState?.currentAccount?.redditor?.commentKarma?.toString() ??
                  "0"),
          Icon(Icons.comment),
        ],
      ),
      onDetailsPressed: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
    );
  }

  List<Widget> buildIcons() {
    if (redditState.isLoggedIn) {
      return redditState.currentAccount.subscriptionOrder.map((String sub) {
        Subreddit subreddit = redditState.currentAccount.subscriptions[sub];
        if (subreddit != null) {
          final menuItem = Padding(
            padding: const EdgeInsets.all(8.0),
            child: SubredditIcon(
              subreddit: subreddit,
              radius: 30.0,
              onTap: () => redditState
                  .changeSubreddit(context, subreddit)
                  .then((_) => Navigator.pop(context)),
            ),
          );
          return menuItem;
        }
      }).toList();
    } else {
      return [];
    }
  }

  Widget buildCompactNormal() {
    return new Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 75.0,
          height: double.infinity,
          child: ListView(
            scrollDirection: Axis.vertical,
            children: buildIcons(),
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                border: Border(
                    left: BorderSide(color: Theme.of(context).primaryColor))),
            child: ListView(
              children: <Widget>[
                buildHeader(),
              ]..addAll(buildMenu()),
            ),
          ),
        )
      ],
    );
  }

  Widget buildCompactExpanded() {
    return new Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 75.0,
          height: double.infinity,
          child: ListView(
            scrollDirection: Axis.vertical,
            children: buildIcons(),
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                border: Border(
                    left: BorderSide(color: Theme.of(context).primaryColor))),
            child: ListView(
              children: <Widget>[
                buildHeader(),
              ]
                ..addAll(buildAccounts())
                ..addAll([
                  buildItem(Icon(Icons.add), Text("Add new Account"), () async {
                    await redditState.login(context);
                    setState(() {});
                  }, true),
                  Divider(),
                  redditState.isLoggedIn
                      ? buildItem(Icon(Icons.cancel), Text("Sign out"),
                          () async {
                          await redditState.logout();
                        }, true)
                      : Container(
                          width: 0.0,
                          height: 0.0,
                        )
                ]),
            ),
          ),
        )
      ],
    );
  }

  Widget buildCompact() {
    return isExpanded ? buildCompactExpanded() : buildCompactNormal();
  }

  Widget buildNonCompact() {
    return isExpanded ? buildNonCompactExpanded() : buildNonCompactNormal();
  }

  @override
  Widget build(BuildContext context) {
    redditState = RedditProvider.of(context);
    var isCompact = redditState.preferences.compactDrawer;
    return Drawer(child: isCompact ? buildCompact() : buildNonCompact());
  }
}
