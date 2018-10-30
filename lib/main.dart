import 'dart:async';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:teatime/items/general/general.dart';
import 'package:teatime/routes.dart';
import 'package:teatime/utils/enums.dart';
import 'package:teatime/utils/preferences.dart';
import 'package:teatime/utils/redditBloc.dart';
import 'package:teatime/utils/redditViewModel.dart';

Future<AppPreferences> loadPreferences() async {
  try {
    return await AppPreferences.get();
  } catch (e) {
    print("Unable to get preferences due to : $e");
    return AppPreferences();
  }
}

void main() async {
//  RegExp exp = RegExp(r"(?<=\/r\/).*(?=\/)");
//  bool isInDebugMode = true;
  var data = await loadPreferences();
  runApp(new MyApp(
    preferenceData: data,
  ));
}

class MyApp extends StatelessWidget {
  final AppPreferences preferenceData;

//  static FirebaseAnalytics analytics = new FirebaseAnalytics();
//  static FirebaseAnalyticsObserver observer =
//      new FirebaseAnalyticsObserver(analytics: analytics);

  const MyApp({Key key, this.preferenceData}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final Router router = new Router();
    Routes.configureRoutes(router);
    var bloc = RedditBloc(preferences: preferenceData);
    bloc.initialize();
    return new RedditProvider(
      data: bloc,
      child: StreamBuilder(
        stream: preferenceData.appThemeStream,
        initialData: preferenceData.appTheme,
        builder: (BuildContext context, AsyncSnapshot<AppThemes> snapshot) {
          if (snapshot.hasData) {
            return new MaterialApp(
//              navigatorObservers: [
//                new FirebaseAnalyticsObserver(analytics: analytics),
//              ],
              title: 'teatime',
              theme: appThemes[snapshot.data.index],
              onGenerateRoute: router.generator,
            );
          }
        },
      ),
    );
  }
}
