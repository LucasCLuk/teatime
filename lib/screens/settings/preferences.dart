import 'package:teatime/utils/redditBloc.dart';
import 'package:teatime/utils/redditViewModel.dart';
import 'package:flutter/material.dart';

class PreferenceManager extends StatefulWidget {
  @override
  _PreferenceManagerState createState() => _PreferenceManagerState();
}

class _PreferenceManagerState extends State<PreferenceManager> {
  RedditBloc redditState;

  StreamBuilder buildTracking() {
    return StreamBuilder(
      stream: redditState.preferences.isTrackingStream,
      builder: (context, snapshot) {
        return SwitchListTile(
            title: Text("History"),
            subtitle: Text("Track subreddits and submissions visited"),
            value: redditState.preferences.isTracking,
            onChanged: (bool value) =>
            redditState.preferences.isTracking = value);
      },
    );
  }

  StreamBuilder buildCompactDrawer() {
    return StreamBuilder(
      stream: redditState.preferences.compactDrawerStream,
      builder: (context, snapshot) {
        return SwitchListTile(
          title: Text("Compact Drawer"),
          subtitle: Text("Display subscriptions as icons instead of text"),
          value: redditState.preferences.compactDrawer,
          onChanged: (bool value) =>
          redditState.preferences.compactDrawer = value,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    redditState = RedditProvider.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Preferences"),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: ListView(
          children: <Widget>[
            buildTracking(),
            buildCompactDrawer(),
          ],
        ),
      ),
    );
  }
}
