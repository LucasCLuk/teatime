import 'dart:async';

import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class CommentBloc {
  final List<String> sortTypes = [
    "confidence",
    "top",
    "new",
    "controversial",
    "old",
    "random",
    "qa",
    "live"
  ];
  final Submission submission;

  final _isUpdated = BehaviorSubject<bool>(seedValue: null);

  Stream<bool> get isUpdatedStream => _isUpdated.stream;

  bool get isUpdated => _isUpdated.value;

  set isUpdated(bool newisUpdated) => _isUpdated.add(newisUpdated);

  final _currentSort = BehaviorSubject<String>(seedValue: null);

  Stream<String> get currentSortStream => _currentSort.stream;

  String get currentSort => _currentSort.value;

  set currentSort(String newcurrentSort) => _currentSort.add(newcurrentSort);

  CommentBloc({@required this.submission}) {
    currentSort = sortTypes[1];
  }

  void loadComments({bool refresh = false}) async {
    if (submission.comments?.length == null || refresh) {
      _isUpdated.add(false);
      try {
        CommentForest forest = await submission.refreshComments(
            params: {"sort": currentSort}).timeout(Duration(seconds: 5));
        try {
          await forest.replaceMore(limit: 100);
        } catch (e) {
          _isUpdated.addError(e);
        }
      } on TimeoutException {
        _isUpdated.add(null);
        return;
      }
    } else {}
    if (!_isUpdated.isClosed) {
      _isUpdated.add(submission.comments.length > 0);
    }
  }

  void changeSort(int sortIndex) {
    currentSort = sortTypes[sortIndex];
    _isUpdated.add(false);
    loadComments(refresh: true);
  }


  Future<Null> loadMoreComments(MoreComments more) async {
    await more.comments(sort: currentSort);
  }

  void dispose() {
    _isUpdated.close();
    _currentSort.close();
  }
}
