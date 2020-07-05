import 'package:flutter/material.dart';

class GroupModel {
  List participants;

  GroupModel({@required this.participants});

  factory GroupModel.fromJson(Map json) {
    return GroupModel(participants: json['participants'] as List);
  }
  Map toJson(GroupModel model) {
    return {'participants': model.participants};
  }
}
