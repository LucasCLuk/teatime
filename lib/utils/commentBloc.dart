import 'dart:async';

import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

// TODO Refresh comments require sorting param

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
  List<dynamic> loadedComments = [];
  Map<String, List<dynamic>> subComments = {};
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
    _isUpdated.add(false);
    if (submission.comments?.length == null || refresh) {
      try {
        CommentForest forest = await submission.refreshComments(
            params: {"sort": currentSort}).timeout(Duration(seconds: 5));
        try {
          await forest.replaceMore(limit: 100);
        } catch (e) {}
        loadedComments.addAll(forest.comments);
      } on TimeoutException {
        _isUpdated.add(null);
        return;
      }
    } else {
      loadedComments.addAll(submission.comments.comments);
    }
    if (!_isUpdated.isClosed) {
      _isUpdated.add(loadedComments.isNotEmpty);
    }
  }

  void changeSort(int sortIndex) {
    currentSort = sortTypes[sortIndex];
    loadedComments.clear();
    _isUpdated.add(false);
    loadComments(refresh: true);
  }

  Future<List<dynamic>> expandReplies(CommentForest forest) async {
    List<dynamic> _queue = [];

    for (var comment in forest.comments) {
      if (comment is Comment) {
        _queue.add(comment);
        if (comment.replies != null) {
          try {
            _queue.addAll(await expandReplies(comment.replies).timeout(Duration(seconds: 5)));
          } catch (e) {
          }
        }
      } else if (comment is MoreComments) {
        _queue.add(comment);
      }
    }
    return _queue;
  }

  Future<Null> loadMoreComments(MoreComments more) async {
    List<dynamic> moreComments = await more.comments(sort: currentSort);
    if (moreComments.isNotEmpty) {
      subComments[more.parentId] = moreComments;
    }
  }

  void dispose() {
    _isUpdated.close();
    _currentSort.close();
  }
}
