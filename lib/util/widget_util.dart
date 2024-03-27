import 'package:flutter/cupertino.dart';

Widget showOnlyWhen(bool show, Widget child) {
  return show ? child : Container();
}