import 'package:event_bus/event_bus.dart';
import 'package:purebook/entity/Book.dart';

EventBus eventBus = new EventBus();

class AddEvent {}

class purebook {
  String name;

  purebook(this.name);
}

class OpenEvent {
  String name;

  OpenEvent(this.name);
}

class PageEvent {
  int page;

  PageEvent(this.page);
}

class SyncShelfEvent {
  String msg;

  SyncShelfEvent(this.msg);
}

class ChapterEvent {
  int chapterId;

  ChapterEvent(this.chapterId);
}

class BooksEvent {
  List<Book> books;

  BooksEvent(this.books);
}
