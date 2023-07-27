import 'package:flutter_learn/conf/const.dart';

List<String> splitName(String fullName) {
  List<String> res = [];
  var names = fullName.split('.');
  // 可能有文件名称为aa.aa.txt
  if (names.length == 0) {
    return res;
  }
  String ext = names[names.length - 1];
  String name = "";
  for (var i = 0; i < names.length - 1; i++) {
    name += names[i];
  }
  res.add(name);
  res.add(ext);
  return res;
}

// 计算未上传的分片
List<int> FindMissChunks(List<int> arr, int total) {
  List<int> res = [];
  if (arr.isEmpty) {
    for (int i = 1; i <= total; i++) {
      res.add(i);
    }
    return res;
  }
  // 不为空
  for (int i = 1; i <= total; i++) {
    if (arr.contains(i)) {
      continue;
    }
    res.add(i);
  }
  return res;
}

String parseSize(int size) {
  double res = size.toDouble();
  if (size > GB) {
    res /= GB;
    return '${res.toStringAsFixed(2)}GB';
  }
  if (size > MB) {
    res /= MB;
    return '${res.toStringAsFixed(2)}MB';
  }
  res /= KB;
  return '${res.toStringAsFixed(2)}KB';
}

String parseSpeed(int cur, int start, int time) {
  double dur = (DateTime.now().microsecondsSinceEpoch - time) / 1000000;
  double speed = (cur.toDouble() - start.toDouble()) / dur;
  if (speed > GB) {
    speed = speed / GB;
    return '${speed.toStringAsFixed(2)}GB/s';
  }
  if (speed > MB) {
    speed = speed / MB;
    return '${speed.toStringAsFixed(2)}MB/s';
  }
  speed /= KB;
  return '${speed.toStringAsFixed(2)}KB/s';
}
