import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:purebook/common/ReaderPageAgent.dart';
import 'package:purebook/common/common.dart';
import 'package:purebook/common/toast.dart';
import 'package:purebook/common/util.dart';
import 'package:purebook/entity/BookInfo.dart';
import 'package:purebook/entity/BookTag.dart';
import 'package:purebook/entity/Chapter.dart';
import 'package:purebook/view/MyViewPage.dart';

class ReadModel with ChangeNotifier {
  BookInfo bookInfo;

  //本书记录
  BookTag bookTag;

  //页面控制器
  MyPageController pageController;

  //章节slider value
  double value;

  //背景色数据
  List<List> bgs = [
    [246, 242, 234],
    [242, 233, 209],
    [231, 241, 231],
    [228, 239, 242],
    [242, 228, 228],
  ];

  //页面字体大小
  double fontSize = 27.0;

  //显示上层 设置
  bool showMenu = false;

  //背景色索引
  int bgIdx = 0;

  //页面宽高
  double contentH;
  double contentW;

  //页面上下文
  BuildContext context;

  //页面显示标志
  bool fix = true;

//是否修改font
  bool font = false;

  //获取本书记录
  getBookRecord() async {
    showMenu = false;
    if (SpUtil.haveKey(bookInfo.Id)) {
      bookTag = BookTag.fromJson(jsonDecode(SpUtil.getString(bookInfo.Id)));
      //slider value
      value = bookTag.cur.toDouble();
      if (bookTag.index > bookTag.pageOffsets.length) {
        bookTag.index = bookTag.pageOffsets.length;
      }
      //书的最后一章
      if (bookInfo.CId == "-1") {
        bookTag.cur = bookTag.chapters.length - 1;
        value = bookTag.cur.toDouble();
      }
//      await getChapters();
//      pageController = MyPageController(initialPage: bookTag.index);
//      notifyListeners();
      //本书已读过
    } else {
      bookTag = BookTag.name();
      if (SpUtil.haveKey('${bookInfo.Id}chapters')) {
        var string = SpUtil.getString('${bookInfo.Id}chapters');
        List v = jsonDecode(string);
        bookTag.chapters = v.map((f) => Chapter.fromJson(f)).toList();
      }
      bookTag.name = bookInfo.Name;
//      pageController = MyPageController(initialPage: 0);

    }
    await asyncInit();
    value = bookTag.cur.toDouble();
  }

  toggleShowMenu() {
    showMenu = !showMenu;
    notifyListeners();
  }

  switchBgColor(i) {
    bgIdx = i;
    notifyListeners();
  }

  Future getChapters() async {
    var url = Common.chaptersUrl + '/${bookInfo.Id}/${bookTag.chapters.length}';
    var ctx;
    if (bookTag.chapters.length == 0 && context != null) {
      ctx = context;
      Toast.show('加载目录...');
    }
    Response response = await Util(ctx).http().get(url);
    log('chapters init ok');
    List data = response.data['data'];
    if (data == null) {
      return;
    }
    log(data.length.toString());
    List<Chapter> list = data.map((c) => Chapter.fromJson(c)).toList();
    bookTag.chapters.addAll(list);
    //书的最后一章
    if (bookInfo.CId == "-1") {
      bookTag.cur = bookTag.chapters.length - 1;
      value = bookTag.cur.toDouble();
    }
  }

  getChapter(int idx, bool pagination) async {
    String id = bookTag.chapters[idx].id;
    if (!SpUtil.haveKey(id)) {
      var url = Common.bookContentUrl + '/$id';

      Response response =
          await Util(pagination ? context : null).http().get(url);
      bookTag.content = response.data['data']['content'].toString().trim();
      //缓存章节
      SpUtil.putString(id, bookTag.content);
      //缓存章节分页
      if (pagination) {
        bookTag.pageOffsets = ReaderPageAgent.getPageOffsets(
            bookTag.content, contentH, contentW, fontSize);
        SpUtil.putString('pages' + id, bookTag.pageOffsets.join('-'));
      }

      bookTag.chapters[idx].hasContent = 2;
    }
  }

  Future<void> asyncInit() async {
    log('chapters init start');
    await getChapters();

    if (bookTag.content == null) {
      log('chapter init start');
      await loadChapter(1);
    }
  }

  chapterToRead(index) {
    bookTag.cur = index;
    bookTag.index = 0;
    loadChapter(1);
  }

  loadChapter(flag) async {
    //flage =g
    if (flag == 1) {
      //f g  g==1 forward =0 back
      getBookChapter(1, 1);
      //预加载下一章
      getBookChapter(0, 1);
    } else {
      getBookChapter(1, 0);
      //预加载上一章
      getBookChapter(0, 0);
    }
    value = bookTag.cur.toDouble();
  }

  justDown(start, end) async {
    for (var i = start; i < end;) {
      if (i == bookTag.chapters.length || i < 0) {
        break;
      }
      String id = bookTag.chapters[i].id;
      if (!SpUtil.haveKey(id)) {
        var url = Common.bookContentUrl + '/$id';
        Response response = await Util(null).http().get(url);
        String content = response.data['data']['content'].toString().trim();
        //缓存章节
        SpUtil.putString(id, content);
        //缓存章节分页
        SpUtil.putString(
            'pages' + id,
            ReaderPageAgent.getPageOffsets(
                    content, contentH, contentW, fontSize)
                .join('-'));
        bookTag.chapters[i].hasContent = 2;
      }
      i++;
    }
  }

  modifyFont() {
    if (!font) {
      font = !font;
    }
    bookTag.index = 0;
    SpUtil.remove('pages${bookTag.chapters[bookTag.cur].id}');
    loadChapter(1);
    notifyListeners();
  }

//f 1 加载  g 1 前进
  getBookChapter(f, g) async {
    //f==0 是预加载
    if (f == 0) {
      int temp = 0;
      if (g == 1) {
        temp = bookTag.cur + 1;
      } else {
        temp = bookTag.cur - 1;
      }
      justDown(temp, temp + 1);
    } else {
      //上一章 需要显示 不是第一章
      int i = bookTag.cur;
      String id = bookTag.chapters[i].id;
      if (SpUtil.haveKey(id)) {
        bookTag.content = SpUtil.getString(id);
        if (SpUtil.haveKey('pages' + id)) {
          bookTag.pageOffsets =
              SpUtil.getString('pages' + bookTag.chapters[i].id)
                  .split('-')
                  .map((f) => int.parse(f))
                  .toList();
        } else {
          bookTag.pageOffsets = ReaderPageAgent.getPageOffsets(
              bookTag.content, contentH, contentW, fontSize);
        }
      } else {
        await getChapter(i, true);
      }
      if (g == 0 && bookTag.cur > 0) {
        bookTag.index = bookTag.pageOffsets.length - 1;
      }
      if (pageController.hasClients) {
        pageController.jumpToPage(bookTag.index);
      }
      notifyListeners();
    }
  }

  prePage() {
    var temp = bookTag.index - 1;
    if (temp >= 0) {
      bookTag.index = temp;
      pageController.jumpToPage(bookTag.index);
    } else {
      int temp = bookTag.cur - 1;
      if (temp < 0) {
        Toast.show('已经是第一页');
      } else {
        bookTag.cur -= 1;
        bookTag.index = 0;
        loadChapter(0);
      }
    }
  }

  //nextpage
  nextPage() {
    log('next page${bookTag.index}');
    var temp = bookTag.index + 1;
    if (temp < bookTag.pageOffsets.length) {
      bookTag.index = temp;
      pageController.jumpToPage(bookTag.index);
    } else {
      int t = bookTag.cur + 1;
      if (t == bookTag.chapters.length) {
        Toast.show('已经是最后一页');
      } else {
        bookTag.cur += 1;
        bookTag.index = 0;
        loadChapter(1);
      }
    }
  }

  saveData() {
    bookTag.content = null;
    SpUtil.putString(bookInfo.Id, jsonEncode(bookTag));
    SpUtil.putDouble('fontSize', fontSize);
    SpUtil.putInt('bgIdx', bgIdx);
  }

  void onPageChange(i) {
    log('滑动${bookTag.index}');
    if (fix) {
      bookTag.index = i;
      notifyListeners();
    } else {
      fix = !fix;
    }
  }

  //当前章节到前一章或后一章
  changePage(int p) {
    fix = !fix;
    if (p > 0) {
      nextPage();
    } else {
      prePage();
    }
  }

  void tapPage(BuildContext context, TapDownDetails details) {
    var wid = ScreenUtil.getScreenW(context);
    var hei = ScreenUtil.getScreenH(context);
    var space = wid / 3;
    var heig = hei / 3;
    var curWid = details.localPosition.dx;
    var curHei = details.localPosition.dy;
    if (curWid > 0 && curWid < space) {
      prePage();
    } else if (curWid > space && curWid < 2 * space && curHei < 2*heig) {
      toggleShowMenu();
    } else {
      nextPage();
    }
  }

  reCalcPages() {
    SpUtil.getKeys().forEach((f) {
      if (f.startsWith('pages')) {
        SpUtil.remove(f);
      }
    });
  }

  downloadAll() async {
    if (bookTag.chapters.isEmpty) {
      getChapters().whenComplete(() async {
        var i = 0;
        for (; i < bookTag.chapters.length;) {
          var id = bookTag.chapters[i].id;
          if (!SpUtil.haveKey(id)) {
            var url = Common.bookContentUrl + '/$id';
            Response response = await Util(null).http().get(url);
            String content = response.data['data']['content'].toString().trim();
            //缓存章节
            SpUtil.putString(id, content);
            bookTag.chapters[i].hasContent = 2;
            i++;
            log(bookTag.chapters[i].name);
          }
        }
      });
      print('menu ok');
    } else {
      print('loop down');
      var i = 0;
      for (; i < bookTag.chapters.length;) {
        var id = bookTag.chapters[i].id;
        if (!SpUtil.haveKey(id)) {
          var url = Common.bookContentUrl + '/$id';
          Response response = await Util(null).http().get(url);
          String content = response.data['data']['content'].toString().trim();
          //缓存章节
          SpUtil.putString(id, content);
          bookTag.chapters[i].hasContent = 2;
          i++;
        }
      }
    }

    Toast.show('${bookInfo.Name}下载完成');
    saveData();
  }

  nextChapter() {
    bookTag.index = 0;
    bookTag.cur += 1;
    loadChapter(1);
  }

  preChapter() {
    bookTag.index = 0;
    bookTag.cur -= 1;
    loadChapter(1);
  }
}
