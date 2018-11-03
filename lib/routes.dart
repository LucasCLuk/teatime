import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:teatime/home.dart';
import 'package:teatime/screens/general/compose_comment.dart';
import 'package:teatime/screens/general/history.dart';
import 'package:teatime/screens/general/search_subreddit.dart';
import 'package:teatime/screens/screens.dart';
import 'package:teatime/screens/settings/menu.dart';
import 'package:teatime/screens/settings/preferences.dart';
import 'package:teatime/screens/sidebar/friends.dart';
import 'package:teatime/utils/redditViewModel.dart';

class Routes {
  static String root = "/";
  static String search = "/search";
  static String inbox = "/inbox";
  static String profile = "/profile";
  static String friends = "/friends";
  static String subreddit = "/r/:subreddit";
  static String users = "/u/:user";
  static String subscriptions = "/subscriptions";
  static String saved = "/saved";
  static String submit = "/submit/:type";
  static String comment = "/comment";
  static String settings = "/settings";
  static String web = "/web/:url";
  static String history = "/history";
  static String preferences = "/preferences";

  static Handler homeHandler(int position) {
    return Handler(
        handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      return Home(
        position: position,
      );
    });
  }

  static Handler searchHandler = new Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    return SearchSubreddit(
      redditState: RedditProvider.of(context),
    );
  });

  static Handler subredditHandler = new Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    return HomeWidget(subreddit: params["subreddit"][0]);
  });

  static Handler subscriptionHandler = new Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    return SubscriptionWidget();
  });

  static Handler savedHandler = new Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    return SavedWidget();
  });

  static Handler userHandler = new Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    var redditState = RedditProvider.of(context);
    var target = params['user'][0];
    var redditor =
        RedditProvider.of(context).reddit.redditor(params['user'][0]);
    return ProfileWidget(
        redditor:
            target != null ? redditor : redditState.currentAccount.redditor);
  });

  static Handler composeSubmissionHandler = new Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    var type = params['type'][0];
    switch (type) {
      case "text":
        return ComposeSubmission(submissionType: SubmissionTypes.self);
      case "link":
        return ComposeSubmission(submissionType: SubmissionTypes.link);
      default:
        return ComposeSubmission(submissionType: SubmissionTypes.self);
    }
  });

  static Handler composeCommentHandler = new Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    return ComposeComment();
  });

  static Handler friendsHandler = new Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    return FriendsList();
  });

  static Handler settingsHandler = new Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    return SettingsMenu();
  });

  static Handler webHandler = new Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    var target = params['url'][0];
    CustomTabsOption option = CustomTabsOption(
      toolbarColor: Theme.of(context).primaryColor,
      enableDefaultShare: false,
      enableUrlBarHiding: true,
      showPageTitle: false,
      animation: new CustomTabsAnimation.slideIn(),
    );
    launch(target, option: option);
  });

  static Handler historyHandler = new Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    return History();
  });

  static Handler preferenceHandler = new Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    return PreferenceManager();
  });

  static void configureRoutes(Router router) {
    router.notFoundHandler = new Handler(
        handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      print("ROUTE WAS NOT FOUND !!!");
      print("Params were:");
      print(params);
      return Container();
    });
    router.define(root, handler: homeHandler(0));
    router.define(search, handler: searchHandler);
    router.define(subreddit, handler: subredditHandler);
    router.define(subscriptions, handler: subscriptionHandler);
    router.define(saved, handler: savedHandler);
    router.define(users, handler: userHandler);
    router.define(submit, handler: composeSubmissionHandler);
    router.define(comment, handler: composeCommentHandler);
    router.define(friends, handler: friendsHandler);
    router.define(settings, handler: settingsHandler);
    router.define(web, handler: webHandler);
    router.define(history, handler: historyHandler);
    router.define(preferences, handler: preferenceHandler);
  }
}
