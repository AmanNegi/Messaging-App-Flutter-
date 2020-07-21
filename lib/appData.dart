import 'package:flutter/cupertino.dart';
import 'package:messaging_app_new/data/strings.dart';
import 'package:messaging_app_new/user/user.dart';

ValueNotifier<User> userData = ValueNotifier<User>(User(imageUrl: demoImage));

setUser(User user) {
  userData.value = user;
}
