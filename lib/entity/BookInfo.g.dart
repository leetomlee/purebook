// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'BookInfo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookInfo _$BookInfoFromJson(Map<String, dynamic> json) {
  return BookInfo(
      json['Author'] as String,
      json['BookStatus'] as String,
      json['BookVote'] == null
          ? null
          : BookVotec.fromJson(json['BookVote'] as Map<String, dynamic>),
      json['CId'] as String,
      json['CName'] as String,
      json['Id'] as String,
      json['Name'] as String,
      json['Img'] as String,
      json['Desc'] as String,
      json['LastChapterId'] as String,
      json['LastChapter'] as String,
      json['FirstChapterId'] as String,
      json['LastTime'] as String,
      (json['SameAuthorBooks'] as List)
          ?.map((e) =>
              e == null ? null : Book.fromJson(e as Map<String, dynamic>))
          ?.toList());
}

Map<String, dynamic> _$BookInfoToJson(BookInfo instance) => <String, dynamic>{
      'Author': instance.Author,
      'BookStatus': instance.BookStatus,
      'BookVote': instance.BookVote,
      'CId': instance.CId,
      'CName': instance.CName,
      'Id': instance.Id,
      'Name': instance.Name,
      'Img': instance.Img,
      'Desc': instance.Desc,
      'LastChapterId': instance.LastChapterId,
      'LastChapter': instance.LastChapter,
      'FirstChapterId': instance.FirstChapterId,
      'LastTime': instance.LastTime,
      'SameAuthorBooks': instance.SameAuthorBooks
    };
