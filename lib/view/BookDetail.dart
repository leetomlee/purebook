import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:purebook/common/Rating.dart';
import 'package:purebook/common/common.dart';
import 'package:purebook/common/toast.dart';
import 'package:purebook/common/util.dart';
import 'package:purebook/entity/Book.dart';
import 'package:purebook/entity/BookInfo.dart';
import 'package:purebook/entity/BookTag.dart';
import 'package:purebook/model/ReadModel.dart';
import 'package:purebook/model/ShelfModel.dart';
import 'package:purebook/store/Store.dart';
import 'package:purebook/view/ReadBook.dart';

import '../main.dart';

class BookDetail extends StatefulWidget {
  BookInfo _bookInfo;

  BookDetail(this._bookInfo);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _BookDetailState(_bookInfo);
  }
}

class _BookDetailState extends State<BookDetail>
    with AutomaticKeepAliveClientMixin {
  BookInfo _bookInfo;
  bool inShelf = false;
  bool down = false;

  _BookDetailState(this._bookInfo);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
        actions: <Widget>[
          GestureDetector(
            child: Center(
              child: Text('书架'),
            ),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => MainPage()));
            },
          ),
          SizedBox(
            width: 20,
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              children: <Widget>[
                Container(
                  child: Row(children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.only(
                              left: 10.0, top: 5.0, bottom: 10.0),
                          child: ExtendedImage.network(
                            _bookInfo.Img,
                            height: 100,
                            width: 80,
                            fit: BoxFit.cover,
                            cache: true,
                          ),
                        )
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.only(left: 20.0, top: 5.0),
                          child: Text(
                            _bookInfo.Name,
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(left: 20.0, top: 2.0),
                          child: Text('作者: ${_bookInfo.Author}',
                              style: TextStyle(fontSize: 12)),
                        ),
                        Container(
                          padding: const EdgeInsets.only(left: 20.0, top: 2.0),
                          child: new Text('类型: ' + _bookInfo.CName,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(fontSize: 12)),
                          width: 270,
                        ),
                        Container(
                          padding: const EdgeInsets.only(left: 20.0, top: 2.0),
                          child: Text('状态: ${_bookInfo.BookStatus}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(fontSize: 12)),
                          width: 270,
                        ),
                        Container(
                            padding: const EdgeInsets.only(
                                left: 15.0, top: 2.0, bottom: 10.0),
                            child: Row(
                              children: <Widget>[
                                Rating(
                                    initialRating:
//                                      _bookInfo.BookVote.Score.toInt(),
                                        2),
                                Text(
//                                  '${_bookInfo.BookVote.Score}分',
                                    '2分')
                              ],
                            )),
                      ],
                    ),
                  ]),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  verticalDirection: VerticalDirection.down,
                  // textDirection:,
                  textBaseline: TextBaseline.alphabetic,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 17.0, top: 5.0),
                      child: Text(
                        '简介',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 17.0, top: 5.0),
                      child: Text(
                        _bookInfo.Desc.trim(),
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                Divider(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  verticalDirection: VerticalDirection.down,
                  // textDirection:,
                  textBaseline: TextBaseline.alphabetic,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 17.0, top: 15.0),
                      child: new Text(
                        '目录',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ListTile(
                      trailing: Icon(Icons.keyboard_arrow_right),
                      leading: Icon(Icons.update),
                      title: Text(
                        '最新: ' + _bookInfo.LastChapter,
                        style: TextStyle(fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        //标志是从书的最后一章开始看
                        _bookInfo.CId = "-1";
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                ReadBook(_bookInfo)));
                      },
                    ),
                  ],
                ),
                Divider(),
                _bookInfo.SameAuthorBooks != null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 17.0, top: 5.0),
                            child: new Text(
                              '${_bookInfo.Author}  还写过',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      )
                    : Container(),
                _bookInfo.SameAuthorBooks != null
                    ? ListView.builder(
                        shrinkWrap: true, //解决无限高度问题
                        physics: NeverScrollableScrollPhysics(), //禁用滑动事件
                        itemBuilder: (context, i) {
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              child: Row(
                                children: <Widget>[
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        padding: const EdgeInsets.only(
                                            left: 10.0, top: 10.0),
                                        child: ExtendedImage.network(
                                          _bookInfo.SameAuthorBooks[i].Img,
                                          height: 100,
                                          width: 80,
                                          fit: BoxFit.cover,
                                          cache: true,
                                        ),
                                      )
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    verticalDirection: VerticalDirection.down,
                                    // textDirection:,
                                    textBaseline: TextBaseline.alphabetic,

                                    children: <Widget>[
                                      Container(
                                          padding: const EdgeInsets.only(
                                              left: 10.0, top: 10.0),
                                          child: Text(
                                            _bookInfo.SameAuthorBooks[i].Name,
                                            style: TextStyle(fontSize: 18.0),
                                          )),
                                      Container(
                                        padding: const EdgeInsets.only(
                                            left: 10.0, top: 10.0),
                                        child: Text(
                                          _bookInfo.SameAuthorBooks[i].Author,
                                          style: TextStyle(fontSize: 12),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.only(
                                            left: 10.0, top: 10.0),
                                        child: Text(
                                            _bookInfo
                                                .SameAuthorBooks[i].LastChapter,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 11)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            onTap: () async {
                              String url = Common.detail +
                                  '/${_bookInfo.SameAuthorBooks[i].Id}';
                              Response future =
                                  await Util(context).http().get(url);
                              var data = future.data['data'];
                              BookInfo bookInfo = BookInfo.fromJson(data);
                              Navigator.of(context).push(new MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      BookDetail(bookInfo)));
                            },
                          );
                        },
                        itemCount: _bookInfo.SameAuthorBooks.length,
                      )
                    : Container(),
              ],
            ),
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        //底部导航栏的创建需要对应的功能标签作为子项，这里我就写了3个，每个子项包含一个图标和一个title。
        items: [
          !Store.value<ShelfModel>(context)
                  .shelf
                  .map((f) => f.Id)
                  .toList()
                  .contains(_bookInfo.Id)
              ? BottomNavigationBarItem(
                  icon: Icon(
                    Icons.playlist_add,
                  ),
                  title: Text(
                    '加入书架',
                  ))
              : BottomNavigationBarItem(
                  icon: Icon(
                    Icons.clear,
                  ),
                  title: new Text(
                    '移除书架',
                  )),
          BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage("images/read.png"),
              ),
              title: Text(
                '立即阅读',
              )),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.cloud_download,
                color: down ? Colors.lightBlue : Colors.black,
              ),
              title: new Text(
                '全本缓存',
              )),
        ],

        onTap: (int i) {
          switch (i) {
            case 0:
              {
                Book book = new Book(
                    "",
                    "",
                    0,
                    _bookInfo.Id,
                    _bookInfo.Name,
                    _bookInfo.Author,
                    _bookInfo.Img,
                    _bookInfo.LastChapterId,
                    _bookInfo.LastChapter,
                    _bookInfo.LastTime);
                Store.value<ShelfModel>(context).modifyShelf(book);
              }
              break;
            case 1:
              {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => ReadBook(_bookInfo)));
              }
              break;
            case 2:
              {
                Toast.show('开始下载...');
                Store.value<ReadModel>(context).bookTag = new BookTag.name();
                Store.value<ReadModel>(context).bookInfo = _bookInfo;
                Store.value<ReadModel>(context).downloadAll();
              }
              break;
          }
        },
      ),
    );
  }

  downAll() async {}

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
