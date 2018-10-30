import 'package:flutter/material.dart';
import 'package:teatime/items/general/general.dart';
import 'package:teatime/items/profile/message.dart';
import 'package:teatime/items/utils/keep_alive.dart';
import 'package:teatime/utils/enums.dart';
import 'package:teatime/utils/listingBloc.dart';
import 'package:teatime/utils/redditBloc.dart';
import 'package:teatime/utils/redditViewModel.dart';

class InboxWidget extends StatefulWidget {
  const InboxWidget({Key key}) : super(key: key);

  @override
  _InboxState createState() => _InboxState();
}

class _InboxState extends State<InboxWidget>
    with RouteAware, SingleTickerProviderStateMixin {
  RedditBloc redditState;
  TabController _tabController;
  ScrollController _scrollViewController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
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
    InboxType.values.forEach(
        (type) => tabs.add(Tab(child: Text(type.toString().split(".")[1]))));
    return tabs;
  }

  @override
  Widget build(BuildContext context) {
    redditState = RedditProvider.of(context);
    return Scaffold(
      body: NestedScrollView(
          headerSliverBuilder: (context, isScrolled) {
            return <Widget>[
              SliverAppBar(
                snap: true,
                floating: true,
                forceElevated: isScrolled,
                title: Text("Inbox"),
                actions: <Widget>[
                  IconButton(icon: Icon(Icons.check), onPressed: null)
                ],
                bottom: TabBar(
                  controller: _tabController,
                  tabs: buildTabs(),
                ),
              )
            ];
          },
          body: TabBarView(controller: _tabController, children: [
            KeepAliveWidget(
              child: ListingBuilder(
                refresh: false,
                listingBloc: ListingBloc(
                    endpoint: "/message/inbox", redditState: redditState),
                builder: (context, item) => MessageWidget(
                      message: item.data,
                    ),
                sliverAppBar: null,
              ),
            ),
            KeepAliveWidget(
              child: ListingBuilder(
                refresh: false,
                listingBloc: ListingBloc(
                    endpoint: "/message/unread", redditState: redditState),
                builder: (context, item) => MessageWidget(
                      message: item.data,
                    ),
                sliverAppBar: null,
              ),
            ),
            KeepAliveWidget(
              child: ListingBuilder(
                refresh: false,
                listingBloc: ListingBloc(
                    endpoint: "/message/sent", redditState: redditState),
                builder: (context, item) => MessageWidget(message: item.data),
                sliverAppBar: null,
              ),
            ),
          ])),
    );
  }
}
