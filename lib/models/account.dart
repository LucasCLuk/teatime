import 'dart:async';

import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:oauth2/oauth2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teatime/utils/preferences.dart';

final List<String> authFields = [
  'accessToken',
  'refreshToken',
  'tokenEndpoint',
  'scopes',
  'expiration',
  'subscriptions'
];

class Account {
  final bool anonymous;
  String accessToken;
  String refreshToken;
  String tokenEndpoint;
  List<dynamic> scopes;
  DateTime expiration;
  String accountName;

  Redditor redditor;
  Reddit reddit;

  User get me => reddit.user;
  Map<String, Subreddit> subscriptions = {};
  List<String> subscriptionOrder = [];
  List<Subreddit> newSubscriptions = [];
  List<Map<String, dynamic>> clickedSubreddits = [];

  @override
  bool operator ==(other) {
    return other.accountName == accountName;
  }

  @override
  // TODO: implement hashCode
  int get hashCode => accountName.hashCode;

  Account({@required this.reddit, this.anonymous = true});

  Account.fromPref(
      {@required Map<String, dynamic> data,
      Reddit state,
      this.anonymous = false}) {
    accessToken = data['accessToken'];
    refreshToken = data['refreshToken'];
    tokenEndpoint = data['tokenEndpoint'];
    scopes = List.castFrom(data['scopes']);
    if (data.containsKey("subscriptions")) {
      (data['subscriptions'] as List<dynamic>)
          .forEach((item) => subscriptionOrder.add((item as String)));
    }
    expiration = DateTime.fromMillisecondsSinceEpoch(data['expiration']);
    reddit = state;
    accountName = data['accountName'];
  }

  Account.fromAuthCredentials(
      {Credentials credentials,
      @required Reddit state,
      this.anonymous = false}) {
    refreshToken = credentials.refreshToken;
    accessToken = credentials.accessToken;
    tokenEndpoint = credentials.tokenEndpoint.toString();
    scopes = credentials.scopes;
    expiration = credentials.expiration;
    reddit = state;
  }

  Map<String, dynamic> authMap() {
    return {
      "accessToken": accessToken,
      "refreshToken": refreshToken,
      "tokenEndpoint": tokenEndpoint,
      "scopes": scopes,
      "expiration": expiration.millisecondsSinceEpoch,
    };
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = authMap();
    data['subscriptions'] = subscriptionOrder;
    data['clicked'] = clickedSubreddits;
    return data;
  }

  Future<Null> refresh() async {
    if (DateTime.now().isAfter(expiration)) {
      await reddit.auth.refresh();
      accessToken = reddit.auth.credentials.accessToken;
      expiration = reddit.auth.credentials.expiration;
    }
  }

  Future<Null> refreshSubscriptions() async {
    subscriptions.clear();
    var _subs = await me.subreddits().toList();
    for (Subreddit subreddit in _subs) {
      subscriptions[subreddit.displayName] = subreddit;
      if (!subscriptionOrder.contains(subreddit.displayName)) {
        newSubscriptions.add(subreddit);
        subscriptionOrder.insert(0, subreddit.displayName);
      }
    }
  }

  Future<Null> getSubscriptions() async {
    var _subs = await me.subreddits().toList();
    for (Subreddit subreddit in _subs) {
      subscriptions[subreddit.displayName] = subreddit;
    }
  }

  Future<Null> unsubscribe(Subreddit subreddit) async {
    if (subscriptions.containsKey(subreddit.displayName)) {
      await subreddit.unsubscribe();
      subscriptionOrder.remove(subreddit.displayName);
      subscriptions.remove(subreddit.displayName);
    }
  }

  Future<Null> subscribe(Subreddit subreddit) async {
    if (!subscriptions.containsKey(subreddit.displayName)) {
      await subreddit.subscribe();
      subscriptionOrder.add(subreddit.displayName);
      subscriptions[subreddit.displayName] = subreddit;
    }
  }

  bool isSubbed(Subreddit subreddit) =>
      subscriptions.containsKey(subreddit.displayName);

  Future<Null> toggleSubscription(Subreddit subreddit) async {
    if (subscriptions.containsKey(subreddit.displayName)) {
      await unsubscribe(subreddit);
    } else {
      await subscribe(subreddit);
    }
  }

  Future<Null> load({Reddit state}) async {
    reddit = state;
    await refresh();
    redditor = await state.user.me();
    await refreshSubscriptions();
  }

  Future<Null> delete() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = toMap();
    data.forEach((String key, dynamic value) {
      var dataType = preferenceToString(value.runtimeType);
      prefs.setValue(dataType, key, null);
    });
  }

  Future<Null> save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = toMap();
    data.forEach((String key, dynamic value) {
      var dataType = preferenceToString(value.runtimeType);
      try {
        prefs.setValue(dataType, key, value);
      } catch (e) {
        print(e);
      }
    });
  }

  Future<Null> saveSubscriptions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList("subscriptions", subscriptionOrder);
  }

  static Future<Map<String, dynamic>> get() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> _data = {};
    for (var item in authFields) {
      _data[item] = await prefs.get(item);
    }
    return _data;
  }

  Future<Null> clickSubreddit(SubredditRef subreddit) async {
    Map<String, dynamic> data = {
      "displayName": subreddit.displayName,
      "visited": DateTime.now().millisecondsSinceEpoch
    };
    clickedSubreddits.add(data);
  }
}
