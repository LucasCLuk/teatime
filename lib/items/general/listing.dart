import 'package:flutter/material.dart';
import 'package:teatime/screens/general/loading_screen.dart';
import 'package:teatime/screens/general/retry.dart';
import 'package:teatime/utils/listingBloc.dart';

typedef ListingWidgetBuilder<T> = Widget Function(
    BuildContext context, ListingSnapShot<T> item);

class ListingSnapShot<T> {
  final T data;

  final int index;

  bool get hasData => data != null;

  ListingSnapShot(this.data, this.index);
}

class ListingBuilder<T> extends StatefulWidget {
  final ListingBloc listingBloc;
  final ListingWidgetBuilder<T> builder;
  final SliverAppBar sliverAppBar;
  final Widget loading;
  final Widget empty;
  final Widget Function(Exception error) error;
  final bool refresh;

  const ListingBuilder({
    Key key,
    @required this.builder,
    @required this.listingBloc,
    @required this.sliverAppBar,
    this.loading,
    this.empty,
    this.error,
    this.refresh = true,
  }) : super(key: key);

  @override
  _ListingState createState() => _ListingState();
}

class _ListingState extends State<ListingBuilder> {
  final ScrollController _scrollController = ScrollController();
  ListingBloc listingBloc;

  @override
  void initState() {
    super.initState();
    listingBloc = widget.listingBloc;
    _scrollController.addListener(_onScroll);
    if (widget.refresh) {
      listingBloc.load();
    } else if (listingBloc.currentSubmissions.isEmpty) {
      listingBloc.load();
    }
    listingBloc.jumpToTopStream
        .listen((bool data) => data == true ? jumpToTop() : null);
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.removeListener(_onScroll);
    if (widget.refresh) listingBloc.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 30 && !listingBloc.isLoading)
      listingBloc.load();
  }

  void jumpToTop() {
    try {
      _scrollController.position
          .jumpTo(_scrollController.position.minScrollExtent + 5);
    } catch (e) {}
  }

  List<Widget> buildSlivers() {
    List<Widget> slivers = [];
    if (widget.sliverAppBar != null) {
      slivers.add(widget.sliverAppBar);
    }
    slivers.add(SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
      var item = listingBloc.currentSubmissions.keys.toList()[index];
      return widget.builder(context,
          ListingSnapShot(listingBloc.currentSubmissions[item], index));
    }, childCount: listingBloc.currentSubmissions.length)));
    return slivers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: new Stack(
        children: <Widget>[
          new StreamBuilder(
            stream: listingBloc.resultsStream,
            initialData: false,
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.hasError) {
                if (widget.error != null) {
                  return widget.error(snapshot.error);
                } else {
                  return RetryWidget(
                    message: Text(snapshot.error.toString()),
                    onTap: () => listingBloc.load(refresh: true),
                  );
                }
              }
              if (listingBloc.currentSubmissions.isNotEmpty) {
                return RefreshIndicator(
                  onRefresh: () => widget.listingBloc.load(refresh: true),
                  child: Scrollbar(
                    child: CustomScrollView(
                      controller: _scrollController,
                      slivers: buildSlivers(),
                    ),
                  ),
                );
              } else if (snapshot.data == false) {
                return widget.loading ?? LoadingScreen();
              } else if (snapshot.data == null) {
                return widget.empty ??
                    RetryWidget(
                        onTap: () => widget.listingBloc.load(
                              refresh: true,
                            ));
              } else {
                return Container(
                  width: 0.0,
                  height: 0.0,
                );
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: new StreamBuilder(
              stream: listingBloc.isLoadingStream,
              initialData: false,
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                if (snapshot.data &&
                    listingBloc.currentSubmissions.isNotEmpty) {
                  return LinearProgressIndicator();
                } else {
                  return Container(
                    width: 0.0,
                    height: 0.0,
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
