import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:teatime/items/items.dart';
import 'package:teatime/items/profile/about.dart';
import 'package:teatime/screens/general/compose_private_message.dart';
import 'package:teatime/screens/general/profile_message.dart';
import 'package:teatime/utils/enums.dart';
import 'package:teatime/utils/redditBloc.dart';
import 'package:teatime/utils/redditViewModel.dart';

class ProfileWidget extends StatefulWidget {
  final RedditorRef redditor;

  const ProfileWidget({Key key, this.redditor}) : super(key: key);

  @override
  _ProfileWidgetState createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget>
    with RouteAware, TickerProviderStateMixin {
  static final meRequired = ['saved', 'hidden'];
  RedditBloc redditState;
  RedditorRef redditor;
  TabController _tabController;
  ScrollController _scrollViewController;
  bool isMe;

  @override
  void initState() {
    super.initState();
    redditor = widget.redditor;
    _scrollViewController = ScrollController(initialScrollOffset: 0.0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollViewController.dispose();
    super.dispose();
  }

  List<Tab> buildTabs() {
    List<Tab> tabs = [];
    for (ProfileTabs tab in ProfileTabs.values) {
      var tabString = tab.toString().split(".")[1];
      if (meRequired.contains(tabString.toLowerCase()) && !isMe) {
        continue;
      }
      tabs.add(Tab(
        text: tabString,
      ));
    }
    return tabs;
  }

  List<Widget> buildTabViews() {
    var tabViews = [
      ProfileMessage(
        redditor: redditor,
        endpoint: "overview",
      ),
      About(redditor: redditor),
      ProfileMessage(redditor: redditor, endpoint: "submitted"),
      ProfileMessage(redditor: redditor, endpoint: "comments"),
    ];
    if (isMe) {
      tabViews.add(
        ProfileMessage(redditor: redditor, endpoint: "hidden"),
      );
      tabViews.add(
        ProfileMessage(redditor: redditor, endpoint: "saved"),
      );
    }
    tabViews.add(
      ProfileMessage(redditor: redditor, endpoint: "gilded"),
    );
    return tabViews;
  }

  @override
  Widget build(BuildContext context) {
    redditState = RedditProvider.of(context);
    redditor ??= redditState.currentAccount.redditor;
    isMe =
        redditor.displayName == redditState.currentAccount.redditor.displayName;
    _tabController = TabController(vsync: this, length: isMe ? 7 : 5);
    var _scaffold = Scaffold.of(context, nullOk: true);
    return Scaffold(
      body: new NestedScrollView(
        controller: _scrollViewController,
        headerSliverBuilder: (context, isScrolled) {
          return <Widget>[
            SliverAppBar(
              snap: true,
              floating: true,
              forceElevated: isScrolled,
              title: Text(redditor?.displayName ?? ""),
              leading: IconButton(
                  icon: Icon(_scaffold != null ? Icons.menu : Icons.arrow_back),
                  onPressed: () {
                    if (_scaffold != null) {
                      Scaffold.of(context).openDrawer();
                    } else {
                      Navigator.pop(context);
                    }
                  }),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) =>
                            ComposePrivateMessage(
                              redditor: redditor.displayName !=
                                      redditState
                                          .currentAccount.redditor.displayName
                                  ? redditor
                                  : null,
                            )));
                  },
                  tooltip: "Send",
                )
              ],
              bottom: TabBar(
                tabs: buildTabs(),
                isScrollable: true,
                controller: _tabController,
              ),
            ),
          ];
        },
        body: new TabBarView(
            controller: _tabController, children: buildTabViews()),
      ),
    );
  }
}
