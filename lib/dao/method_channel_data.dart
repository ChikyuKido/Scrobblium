
import 'dart:typed_data';

import 'package:scrobblium/util/util.dart';

class MethodChannelData {
  String? error;
  List<int>? data;

  MethodChannelData(this.error, this.data);

  bool hasError() {
    return error != null;
  }
  bool hasNotError() {
    return error == null;
  }

  void showErrorAsToastIfAvailable() {
    if(hasError()) {
      showToast(error!);
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'error': error,
      'data': data,
    };
  }

  factory MethodChannelData.fromMap(Map<String, dynamic> map) {
    return MethodChannelData(
        map['error'],
        map['data']
    );
  }
}