import 'package:scrobblium/util/widget_util.dart';

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

  String getDataAsString() {
    return String.fromCharCodes(data??List.empty());
  }
  int getDataAsInt() {
    if(data == null) return 0;
    return data!.fold(0, (prev, elem) => (prev << 8) | elem);
  }
  bool getDataAsBool() {
    if(data == null) return false;
    return data?.first == 1;
  }

  void showErrorAsToastIfAvailable() {
    if(hasError()) {
      WidgetUtil.showToast(error!);
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