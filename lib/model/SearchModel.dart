import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:purebook/common/common.dart';
import 'package:purebook/common/util.dart';
import 'package:purebook/entity/SearchItem.dart';

class SearchModel with ChangeNotifier {
  List<String> searchHistory = new List();
  BuildContext context;
  bool showResult = false;
  List<SearchItem> bks = [];
  int page = 1;
  int size = 10;
  var word = "";
  RefreshController refreshController =
      RefreshController(initialRefresh: false);
  TextEditingController controller;

  List<Color> colors = Colors.accents;

  getSearchData() async {
    //收起键盘
    FocusScope.of(context).requestFocus(FocusNode());
    var ctx;
    if (bks.length == 0) {
      ctx = context;
    }
    var url = '${Common.search}?key=$word&page=$page&size=$size';

    Response res = await Util(ctx).http().get(url);
    List data = res.data['data'];
    if (data == null) {
      refreshController.loadNoData();
    } else {
      data.forEach((f) {
        bks.add(SearchItem.fromJson(f));
      });
    }
  }

  void onRefresh() async {
    bks = [];
    page = 1;
    getSearchData();
    refreshController.refreshCompleted();
    notifyListeners();
  }

  void onLoading() async {
    page += 1;
    getSearchData();
    refreshController.loadComplete();
    notifyListeners();
  }

  toggleShowResult() {
    showResult = !showResult;
    notifyListeners();
  }

  List<Widget> getHistory() {

    List<Widget> wds = [];
    for (var value in searchHistory) {
      wds.add(GestureDetector(
        onTap: () {
          word = value;
          controller.text=value;
          search(value);
          notifyListeners();
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 1.0), //灰色的一层边框
            color: colors[Random().nextInt(colors.length)],
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
          ),
          alignment: Alignment.center,
          width: 80,
          child: Center(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ));
    }

    return wds;
  }

  setHistory(String value) {
    if (value.isEmpty) {
      return;
    }
    for (var ii = 0; ii < searchHistory.length; ii++) {
      if (searchHistory[ii] == value) {
        searchHistory.removeAt(ii);
      }
    }
    searchHistory.insert(0, value);
    if (SpUtil.haveKey('history')) {
      SpUtil.remove('history');
    }
    SpUtil.putStringList('history', searchHistory);
  }

  initHistory() {
    if (SpUtil.haveKey('history')) {
      searchHistory = SpUtil.getStringList('history');
    }
    notifyListeners();
  }

  clearHistory() {
    SpUtil.remove('history');
    searchHistory = [];
    notifyListeners();
  }

  reset() {
    if (word.isEmpty) {
      return;
    }
    word = "";
    toggleShowResult();
    notifyListeners();
  }

  Future<void> search(String w) async {
    if (w.isEmpty) {
      return;
    }
    bks = [];
    toggleShowResult();
    word = w;
    await getSearchData();
    setHistory(w);
    notifyListeners();
  }
}
