import 'package:teatime/utils/utils.dart';
import 'package:flutter/material.dart';

class SettingsMenu extends StatefulWidget {
  @override
  _SettingsMenuState createState() => _SettingsMenuState();
}

class _SettingsMenuState extends State<SettingsMenu> {
  @override
  Widget build(BuildContext context) {
    RedditBloc redditBloc = RedditProvider.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.security),
            title: Text("Preferences"),
            subtitle: Text("Manage app preferences"),
            onTap: () => Navigator.pushNamed(context, "/preferences"),
          ),
          AboutListTile(
            applicationVersion: "Version : ${redditBloc.packageInfo.version}",
            applicationName: "teatime",
            aboutBoxChildren: <Widget>[
              Text("Written in dart's Flutter framework")
            ],
            child: Text("About"),
            icon: Icon(Icons.info),
          )
        ],
      ),
    );
  }
}
