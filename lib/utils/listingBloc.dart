import 'dart:async';

import 'package:draw/draw.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:teatime/utils/redditBloc.dart';

class ListingBloc {
  final defaultParams = {"g": "CA", "limit": "10"};
  final RedditBloc redditState;
  final Map<String, String> params;
  final bool isListing;
  final bool useDefaults;
  final bool isSubreddit;
  final _isLoadingSubject = PublishSubject<bool>();
  final resultsSubject = PublishSubject<bool>();
  final _jumpToTopSubject = PublishSubject<bool>();
  final _endpointSubject = PublishSubject<String>();

  Stream<String> get endpointStream => _endpointSubject.stream;

  String _endpoint = "/";

  String get endpoint => _endpoint;

  set endpoint(String newEndpoint) => _endpointSubject.add(newEndpoint);

  Stream<bool> get jumpToTopStream => _jumpToTopSubject.stream;

  Stream<bool> get isLoadingStream => _isLoadingSubject.stream;

  bool isLoading = false;
  String after;
  Map<String, dynamic> currentSubmissions = {};

  ListingBloc(
      {@required String endpoint,
      @required this.redditState,
      this.useDefaults = true,
      this.isSubreddit = false,
      this.params,
      this.isListing = true}) {
    _endpoint = endpoint;
    _endpointSubject.add(endpoint);
    _endpointSubject.listen((String ep) {
      _jumpToTopSubject.add(true);
      _endpoint = ep;
      load(refresh: true);
    });
  }

  Stream<bool> get resultsStream => resultsSubject.stream;

  void jumpToTop() {
    _jumpToTopSubject.add(true);
  }

  Future<Null> load({bool refresh = false}) async {
    String _requestEndpoint = _endpoint;
    String _currentSort;
    if (isLoading || redditState.reddit == null) {
      return;
    }
    isLoading = true;
    resultsSubject.add(false);
    if (refresh) {
      after = null;
      clear();
    }
    Map<String, String> _params = params ?? {};
    List<dynamic> apiResults = [];
    _currentSort = redditState.preferences.currentSort.toString().split(".")[1];
    if (_currentSort == "newest") {
      _currentSort = "new";
    }
    if (useDefaults) _params.addAll(defaultParams);
    try {
      if (isListing) {
        _params['sort'] = _currentSort;
        _params['t'] =
            redditState.preferences.currentRange.toString().split(".")[1];
        _params.addAll(params ?? {});
        if (currentSubmissions.isNotEmpty == true && after != null) {
          _params['count'] = "${currentSubmissions.length}";
          _params['after'] = after;
        }
      }
      if (isSubreddit) _requestEndpoint = "$_requestEndpoint$_currentSort";
      dynamic response = await redditState.reddit
          .get("$_requestEndpoint", params: _params.isNotEmpty ? _params : null)
          .timeout(Duration(seconds: 5));
      if (isListing || response.containsKey("listing")) {
        apiResults = response.remove("listing");
        after = response.remove("after");
      } else {
        apiResults = response;
      }
      if (apiResults.isEmpty) {
        if (!resultsSubject.isClosed) {
          resultsSubject.add(null);
        }
        return;
      }
      Map<String, dynamic> data = {};
      for (dynamic value in apiResults) {
        if (value is Submission) {
          if (value.over18 && redditState.preferences.filterNSFW) {
            continue;
          }
        }
        data[value.fullname] = value;
      }
      if (data.isNotEmpty) {
        currentSubmissions.addAll(data);
      }
      if (!resultsSubject.isClosed) {
        resultsSubject.add(data.isNotEmpty);
      }
    } catch (e) {
      if (!resultsSubject.isClosed) {
        resultsSubject.addError(e);
      }
    } finally {
      isLoading = false;
    }
  }

  void clearRead() {
    currentSubmissions.removeWhere((String key, dynamic value) =>
        redditState.preferences.clicked.contains(key));
    resultsSubject.add(currentSubmissions.isNotEmpty);
  }

  Future<Null> refreshSubmission(dynamic target) async {
    if (currentSubmissions.containsKey(target.fullname)) {
      await target.refresh();
    }
  }

  void hide({Submission post}) {
    currentSubmissions.remove(post.fullname);
    resultsSubject.add(true);
  }

  void clear() {
    currentSubmissions.clear();
    resultsSubject.add(true);
  }

  void dispose() {
    currentSubmissions.clear();
    resultsSubject.add(null);
    resultsSubject.close();
    _isLoadingSubject.close();
    _jumpToTopSubject.close();
    _endpointSubject.close();
  }
}
