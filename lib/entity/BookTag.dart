import 'package:json_annotation/json_annotation.dart';
import 'package:purebook/entity/Chapter.dart';

part 'BookTag.g.dart';

@JsonSerializable()
class BookTag {
  int cur = 0;
  int index = 0;
  String bookName;
  List<Chapter> chapters = [];

  factory BookTag.fromJson(Map<String, dynamic> json) =>
      _$BookTagFromJson(json);

  Map<String, dynamic> toJson() => _$BookTagToJson(this);

  BookTag(this.cur, this.index, this.chapters);

  BookTag.bookName(this.bookName);
}
