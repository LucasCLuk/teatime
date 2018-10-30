import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:oauth2/oauth2.dart';
import 'package:path_provider/path_provider.dart';

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

  Account.fromJson(
      {@required Map<String, dynamic> data,
      Reddit state,
      this.anonymous = false}) {
    accessToken = data['accessToken'];
    refreshToken = data['refreshToken'];
    tokenEndpoint = data['tokenEndpoint'];
    scopes = List.castFrom(data['scopes']);
    (data['subscriptions'] as List<dynamic>)
        .forEach((item) => subscriptionOrder.add((item as String)));
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
    data['expiration'] = expiration.millisecondsSinceEpoch;
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
    await getSubscriptions();
  }

  static Future<File> _getFile(String accountName) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    File fileData = File("$appDocPath/$accountName.json");
    return fileData;
  }

  static Future<Null> delete(String accountName) async {
    File fileData = await _getFile(accountName);
    await fileData.delete();
  }

  Future<Null> save() async {
    File fileData = await _getFile(accountName);
    await fileData.writeAsString(json.encode(toMap()));
  }

  static Future<Map<String,dynamic>> get(String accountName) async {
    File fileData = await _getFile(accountName);
    try {
      var data = json.decode(await fileData.readAsString());
      return data;
    } catch (e) {
      return null;
    }
  }

  Future<Null> clickSubreddit(Subreddit subreddit) async {
    Map<String, dynamic> data = {
      "displayName": subreddit.displayName,
      "visited": DateTime.now().millisecondsSinceEpoch
    };
    clickedSubreddits.add(data);
    save();
  }

}
