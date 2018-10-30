import 'dart:async';

import 'package:package_info/package_info.dart';

class RedditCredentials {
  final String userAgent, clientId, clientSecret;
  final Uri redirectUri;
  final List<String> scopes;

  RedditCredentials._fromData(this.userAgent, this.clientId, this.clientSecret,
      this.redirectUri, this.scopes);

  static Future<String> _buildUA(PackageInfo packageInfo) async {
    return "Teatime ${packageInfo.packageName}:${packageInfo.version} (by /u/darkkmello)";
  }

  static Future<RedditCredentials> buildRedditCredentials(
      PackageInfo packageInfo) async {
    final String clientId = "x0fNHmKmmJAOag";
    final String clientSecret = "";
    final Uri redirectUri =
        Uri(host: "127.0.0.1", port: 4356, path: "/", scheme: "http");
    final List<String> scopes = [
      "identity",
      "edit",
      "flair",
      "history",
      "modconfig",
      "modflair",
      "modlog",
      "modposts",
      "modwiki",
      "mysubreddits",
      "privatemessages",
      "read",
      "report",
      "save",
      "submit",
      "subscribe",
      "vote",
      "wikiedit",
      "wikiread"
    ];

    return RedditCredentials._fromData(await _buildUA(packageInfo), clientId,
        clientSecret, redirectUri, scopes);
  }
}
