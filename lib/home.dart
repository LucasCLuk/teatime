import 'dart:async';

import 'package:teatime/drawer.dart';
import 'package:teatime/items/general/general.dart';
import 'package:teatime/screens/general/retry.dart';
import 'package:teatime/screens/screens.dart';
import 'package:teatime/utils/enums.dart';
import 'package:teatime/utils/redditBloc.dart';
import 'package:teatime/utils/redditViewModel.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  final int position;

  const Home({Key key, this.position = 0}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home>
    with SingleTickerProviderStateMixin, RouteAware {
  final Map<BottomScreens, Map<String, dynamic>> _bottomNavigationItems = {};
  final Map<String, Icon> bottomSheetItems = {
    "link": Icon(Icons.link),
//    "image": Icon(Icons.image),
//    "video": Icon(Icons.video_call),
    "text": Icon(Icons.comment)
  };
  final PageStorageBucket bucket = PageStorageBucket();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  bool hideBottomNav = false;
  RedditBloc redditState;

  Future<Null> manageBackPressed() async {
    if (redditState.currentPosition != BottomScreens.home) {
      redditState.currentPosition = BottomScreens.home;
    }
  }

  void showPostMenu() {
    List<Widget> bottomItems = [];
    bottomSheetItems.forEach((label, icon) => bottomItems.add(Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Column(
            children: <Widget>[
              InkWell(
                onTap: () =>
                    Navigator.of(context).popAndPushNamed("/submit/$label"),
                child: CircleAvatar(
                  child: icon,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(label.toUpperCase()),
              )
            ],
          ),
        )));
    showModalBottomSheet(
        context: context,
        builder: (context) => Container(
              height: 100.0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: bottomItems,
              ),
            ));
  }

  Widget buildHome() {
    for (BottomScreens screen in BottomScreens.values) {
      var data = BottomNavigationScreens.screenMapping[screen];
      String screenName = screen.toString().split(".")[1];
      _bottomNavigationItems[screen] = {
        "widget": BottomNavigationScreens.builder(context, screen),
        "bar": BottomNavigationBarItem(
            icon: Icon(data['icon'],
                color: loginRequiredScreens.contains(screen) &&
                        !redditState.isLoggedIn
                    ? Theme.of(context).disabledColor
                    : Theme.of(context).iconTheme.color),
            title: Text(screenName))
      };
    }
    return StreamBuilder(
      stream: redditState.currentPositionStream,
      initialData: BottomScreens.home,
      builder: (BuildContext context, AsyncSnapshot<BottomScreens> snapshot) {
        if (snapshot.data != BottomScreens.home) {
          return WillPopScope(
              child: _buildScaffold(), onWillPop: manageBackPressed);
        } else {
          return _buildScaffold();
        }
      },
    );
  }

  List<BottomNavigationBarItem> buildBottomBarItems() {
    List<BottomNavigationBarItem> items = [];
    _bottomNavigationItems.values
        .forEach((Map<String, dynamic> data) => items.add(data['bar']));
    return items;
  }

  Scaffold _buildScaffold() {
    return new Scaffold(
      key: scaffoldKey,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex:
            redditState.currentPosition.index ?? BottomScreens.home.index,
        type: BottomNavigationBarType.fixed,
        items: buildBottomBarItems(),
        onTap: (index) {
          if (BottomScreens.post.index == index) {
            if (!redditState.isLoggedIn) {
              redditState.showSnackBar("Required to be logged in");
              return;
            } else {
              showPostMenu();
            }
          } else {
            redditState.currentPosition = BottomScreens.values[index];
          }
        },
      ),
      body: PageStorage(
          bucket: bucket,
          child: _bottomNavigationItems[redditState.currentPosition]
                  ["widget"] ??
              LoadingScreen()),
      drawer: MyDrawer(),
    );
  }

  @override
  Widget build(BuildContext context) {
    redditState = RedditProvider.of(context);
    return new StreamBuilder<bool>(
        stream: redditState.isBuiltStream,
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasError) {
            return RetryWidget(
              message: Text(snapshot.error.toString()),
              onTap: () => redditState.initialize(),
            );
          } else if (snapshot.data == true) {
            return buildHome();
          } else {
            return LoadingScreen();
          }
        });
  }
}
