import 'dart:io';

import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:purebook/model/ColorModel.dart';
import 'package:purebook/service/TelAndSmsService.dart';
import 'package:purebook/store/Store.dart';
import 'package:purebook/view/BookShelf.dart';
import 'package:purebook/view/Me.dart';
import 'package:purebook/view/PersonCenter.dart';
import 'package:purebook/view/Search.dart';

import 'event/event.dart';

GetIt locator = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SpUtil.getInstance();
  await DirectoryUtil.getInstance();
  locator.registerSingleton(TelAndSmsService());
  runApp(Store.init(child: MyApp()));
  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle =
        SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Store.value<ColorModel>(context).theme,
      title: '清阅',
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _tabIndex = 0;

  var _pageController = PageController();
  List<BottomNavigationBarItem> bottoms = [
    BottomNavigationBarItem(
        icon: ImageIcon(
          AssetImage("images/book_shelf.png"),
        ),
        title: Text(
          '书架',
        )),
    BottomNavigationBarItem(
        icon: ImageIcon(
          AssetImage("images/search.png"),
        ),
        title: Text(
          '搜索',
        )),
    BottomNavigationBarItem(
        icon: ImageIcon(
          AssetImage("images/account.png"),
        ),
        title: Text(
          '我的',
        )),
  ];

  /*
   * 存储的四个页面，和Fragment一样
   */
  var _pages = [BookShelf(), Search(), Me()];
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: PersonCenter(),
      ),
      key: _scaffoldKey,
      body: PageView.builder(
          //要点1
          physics: NeverScrollableScrollPhysics(),
          //禁止页面左右滑动切换
          controller: _pageController,
          onPageChanged: _pageChanged,
          //回调函数
          itemCount: _pages.length,
          itemBuilder: (context, index) => _pages[index]),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        items: bottoms,
        type: BottomNavigationBarType.fixed,
        currentIndex: _tabIndex,
        onTap: (index) {
          _pageController.jumpToPage(index);
        },
      ),
    );
  }

  void _pageChanged(int index) {
    setState(() {
      if (_tabIndex != index) _tabIndex = index;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    eventBus.on<BooksEvent>().listen((BooksEvent booksEvent) => closeDrawer());
    eventBus.on<OpenEvent>().listen((OpenEvent openEvent) => openDrawer());
    eventBus
        .on<SyncShelfEvent>()
        .listen((SyncShelfEvent booksEvent) => closeDrawer());
  }

  closeDrawer() {
    _scaffoldKey.currentState.openEndDrawer();
  }

  openDrawer() {
    _scaffoldKey.currentState.openDrawer();
  }
}
