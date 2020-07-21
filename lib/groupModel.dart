import 'package:flutter/material.dart';

class GroupModel {
  List participants;
  DateTime date;
  //last message date

  GroupModel({@required this.participants, @required this.date});

  factory GroupModel.fromJson(Map json) {
    return GroupModel(
        participants: json['participants'] as List,
        date: json['date'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(
                json['date'].millisecondsSinceEpoch));
  }
  Map toJson() {
    return {'participants': participants, 'date': date};
  }
}
