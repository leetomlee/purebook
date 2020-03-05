import 'package:json_annotation/json_annotation.dart';
import 'package:purebook/entity/Chapter.dart';

part 'BookTag.g.dart';

@JsonSerializable()
class BookTag {
  List<int> pageOffsets = [];

  String content;
  String name = "";
  int cur = 0;
  int index = 0;
  List<Chapter> chapters = [];

  String stringAtPageIndex(int index) {
    return this.content.substring(
        index - 1 == -1 ? 0 : pageOffsets[index - 1], pageOffsets[index]);
  }

  int get pageCount {
    return pageOffsets.length;
  }

  factory BookTag.fromJson(Map<String, dynamic> json) =>
      _$BookTagFromJson(json);

  Map<String, dynamic> toJson() => _$BookTagToJson(this);

  BookTag(this.pageOffsets, this.content, this.name, this.cur, this.index,
      this.chapters);

  BookTag.name();
}
