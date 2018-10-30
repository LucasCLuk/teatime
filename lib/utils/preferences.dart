import 'dart:async';
import 'dart:collection';

import 'package:draw/draw.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teatime/models/models.dart';
import 'package:teatime/utils/enums.dart';
import 'package:teatime/utils/utils.dart';
import 'package:uuid/uuid.dart';

String preferenceToString(Type type) {
  switch (type) {
    case bool:
      return "Bool";
    case double:
      return "Double";
    case int:
      return "Int";
    case String:
      return "String";
    case List:
      return "StringList";
    default:
      return "";
  }
}

class AppPreferences {
  String uuid;
  String currentAccountName;

  bool get nightTheme => appTheme == AppThemes.dark ? true : false;

  final _currentAccountSubject = PublishSubject<Account>();

  Stream<Account> get currentAccountStream => _currentAccountSubject.stream;

  Account _currentAccount;

  Account get currentAccount => _currentAccount;

  set currentAccount(Account newcurrentAccount) {
    if (newcurrentAccount == null) {
      currentAccountName = null;
      _currentAccountSubject.add(null);
    } else {
      currentAccountName = newcurrentAccount.accountName;
      _currentAccountSubject.add(newcurrentAccount);
    }
  }

  final _appThemeSubject = PublishSubject<AppThemes>();

  Stream<AppThemes> get appThemeStream => _appThemeSubject.stream;

  AppThemes _appTheme;

  AppThemes get appTheme => _appTheme;

  set appTheme(AppThemes newappTheme) {
    _appTheme = newappTheme;
    _appThemeSubject.add(newappTheme);
  }

  final _filterNSFWSubject = PublishSubject<bool>();

  Stream<bool> get filterNSFWStream => _filterNSFWSubject.stream;

  bool _filterNSFW;

  bool get filterNSFW => _filterNSFW;

  set filterNSFW(bool newfilterNSFW) {
    _filterNSFW = newfilterNSFW;
    _filterNSFWSubject.add(newfilterNSFW);
  }

  final _currentSortSubject = PublishSubject<SupportedSortTypes>();

  Stream<SupportedSortTypes> get currentSortStream =>
      _currentSortSubject.stream;

  SupportedSortTypes _currentSort;

  SupportedSortTypes get currentSort => _currentSort;

  set currentSort(SupportedSortTypes newcurrentSort) {
    _currentSort = newcurrentSort;
    _currentSortSubject.add(newcurrentSort);
  }

  final _currentRangeSubject = PublishSubject<PostRange>();

  Stream<PostRange> get currentRangeStream => _currentRangeSubject.stream;

  PostRange _currentRange;

  PostRange get currentRange => _currentRange;

  set currentRange(PostRange newcurrentRange) {
    _currentRange = newcurrentRange;
    _currentRangeSubject.add(newcurrentRange);
  }

  final _isTrackingSubject = PublishSubject<bool>();

  Stream<bool> get isTrackingStream => _isTrackingSubject.stream;

  bool _isTracking;

  bool get isTracking => _isTracking;

  set isTracking(bool newisTracking) {
    _isTracking = newisTracking;
    _isTrackingSubject.add(newisTracking);
  }

  final _compactDrawerSubject = PublishSubject<bool>();

  Stream<bool> get compactDrawerStream => _compactDrawerSubject.stream;

  bool _compactDrawer;

  bool get compactDrawer => _compactDrawer;

  set compactDrawer(bool newcompactDrawer) {
    _compactDrawer = newcompactDrawer;
    _compactDrawerSubject.add(newcompactDrawer);
  }

  List<String> linkedAccountNames = [];
  Queue<String> clicked = Queue();

  AppPreferences() {
    _addListeners();
  }

  AppPreferences.fromPreferences(SharedPreferences preferences) {
    uuid = preferences.getString("uuid") ?? Uuid().v4();
    appTheme = AppThemes.values[preferences.getInt("theme") ?? 1];
    filterNSFW = preferences.getBool("filterNSFW") ?? true;
    currentSort =
        SupportedSortTypes.values[preferences.getInt('currentSort') ?? 0];
    currentRange = PostRange.values[preferences.getInt('currentRange') ?? 0];
    compactDrawer = preferences.getBool("compactDrawer") ?? false;
    isTracking = preferences.getBool("isTracking") ?? true;
    currentAccountName = preferences.getString('currentAccount');
    linkedAccountNames = preferences.getStringList("linkedAccounts") ?? [];
    clicked = Queue.from(preferences.getStringList("clicked") ?? []);
    _addListeners();
  }

  Map<String, dynamic> toMap() {
    return {
      "theme": appTheme.index,
      "currentSort": currentSort.index,
      "currentRange": currentRange.index,
      "filterNSFW": filterNSFW,
      "linkedAccounts":
          linkedAccountNames.isNotEmpty ? linkedAccountNames : null,
      "isTracking": _isTracking,
      "compactDrawer": _compactDrawer,
      "clicked": clicked,
      "currentAccount": currentAccountName,
      "uuid": uuid,
    };
  }

  void dispose() {
    _appThemeSubject.close();
    _filterNSFWSubject.close();
    _isTrackingSubject.close();
    _currentSortSubject.close();
    _currentRangeSubject.close();
    _currentAccountSubject.close();
    _compactDrawerSubject.close();
  }

  void _addListeners() {
    _currentAccountSubject.listen((Account newAccount) =>
        saveField("currentAccount", newAccount?.accountName, "String"));
    _appThemeSubject.listen(
        (AppThemes newTheme) => saveField("theme", newTheme.index, "Int"));
    _filterNSFWSubject
        .listen((bool newFilter) => saveField("filterNSFW", newFilter, "Bool"));
    _currentSortSubject.listen((SupportedSortTypes newSort) =>
        saveField("currentSort", newSort.index, "Int"));
    _currentRangeSubject.listen((PostRange newRange) =>
        saveField("currentRange", newRange.index, "Int"));
    _isTrackingSubject.listen(
        (bool newTracking) => saveField("isTracking", newTracking, "Bool"));
    _compactDrawerSubject.listen(
        (bool isCompact) => saveField("compactDrawer", isCompact, "Bool"));
  }

  static Future<AppPreferences> get() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return AppPreferences.fromPreferences(prefs);
  }

  Future<Null> addAccount({Reddit state}) async {
    Account _newAccount = Account.fromAuthCredentials(
        credentials: state.auth.credentials, state: state);
    _newAccount.redditor = await state.user.me();
    _newAccount.accountName = _newAccount.redditor.displayName;
    var _subscriptions = await state.user.subreddits().toList();
    _subscriptions.forEach((Subreddit sub) {
      _newAccount.subscriptionOrder.add(sub.displayName);
      _newAccount.subscriptions[sub.displayName] = sub;
    });
    _newAccount.subscriptionOrder.sort((a, b) => a.compareTo(b));
    currentAccountName = _newAccount.accountName;
    _currentAccount = _newAccount;
    linkedAccountNames.add(_newAccount.accountName);
    await save();
    await _newAccount.save();
    _currentAccountSubject.add(_newAccount);
  }

  Future<Null> saveField(
      String fieldName, dynamic fieldData, String fieldType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setValue(fieldType, fieldName, fieldData);
  }

  Future<Null> _toPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = toMap();
    data.forEach((String key, dynamic value) {
      var dataType = preferenceToString(value.runtimeType);
      prefs.setValue(dataType, key, value);
    });
  }

  Future<Null> save() async {
    await _toPreferences();
  }

  Future<Null> clickPost(Submission submission) async {
    if (isTracking && !clicked.contains(submission.fullname)) {
      clicked.addFirst(submission.fullname);
      await saveField("clicked", clicked.toList(), "StringList");
    }
  }

  void clearHistory() async {
    clicked.clear();
    await saveField("clicked", clicked.toList(), "StringList");
  }

  bool isClicked(Submission post) => clicked.contains(post.fullname);

  void unRead(dynamic submission) {
    clicked.remove(submission.fullname);
    submission.markUnread();
    save();
  }

  Future<Null> loadCurrentAccount() async {
    var data = await Account.get(currentAccountName);
    if (data != null) {
      _currentAccount = Account.fromJson(data: data);
    }
  }

  Future<Null> deleteAccount(String accountName) async {
    linkedAccountNames.removeWhere((key) => key == accountName);
    await save();
    var data = await Account.get(
        linkedAccountNames.isNotEmpty ? linkedAccountNames.first : null);
    if (data != null)
      _currentAccountSubject.add(Account.fromJson(state: null, data: data));
    currentAccountName = null;
    _currentAccount = null;
  }
}
