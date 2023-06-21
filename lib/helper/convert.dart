import 'dart:convert';

import 'package:flutter_learn/controller/file_controller.dart';

abstract class Convert {
  // Transform create();
  dynamic transform(dynamic data);
}

class JSONConvert extends Convert {
  @override
  dynamic transform(data) {
    return jsonDecode(data);
  }

  String encodeJson(data) {
    return jsonEncode(data);
  }

  // Transform create() {
  //   return JsonTransform();
  // }
  static JSONConvert create() {
    return JSONConvert();
  }
}

FileController deepCopyFC(FileController ori) {
  FileController res = FileController();
  res.token = ori.token;
  res.fileObjs = [...ori.fileObjs];
  res.page = ori.page;
  res.dirList = [...ori.dirList];
  res.nameList = [...ori.nameList];
  res.curDir = ori.curDir;
  res.curName = ori.curName;
  res.taskMap = {...ori.taskMap};

  return res;
}
