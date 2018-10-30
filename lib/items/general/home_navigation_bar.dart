import 'package:teatime/screens/screens.dart';
import 'package:teatime/utils/enums.dart';
import 'package:teatime/utils/redditViewModel.dart';
import 'package:flutter/material.dart';

class BottomNavigationScreens {
  static final screenMapping = {
    BottomScreens.home: {
      "icon": Icons.home,
    },
    BottomScreens.search: {
      "icon": Icons.search,
    },
    BottomScreens.post: {
      "icon": Icons.send,
    },
    BottomScreens.inbox: {
      "icon": Icons.inbox,
    },
    BottomScreens.profile: {
      "icon": Icons.account_circle,
    }
  };

  static Widget builder(BuildContext context, BottomScreens screen) {
    switch (screen) {
      case BottomScreens.home:
        return HomeWidget(redditState: RedditProvider.of(context),
            key: PageStorageKey("HomeScreen"));
      case BottomScreens.search:
        return SearchPage(
          key: PageStorageKey("SearchScreen"),
        );
      case BottomScreens.post:
        return Container(
          key: PageStorageKey("PostScreen"),
        );
      case BottomScreens.inbox:
        return InboxWidget(
          key: PageStorageKey("InboxScreen"),
        );
      case BottomScreens.profile:
        return ProfileWidget(
          key: PageStorageKey("ProfileScreen"),
        );
      default:
        return Container();
    }
  }
}
