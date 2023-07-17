List<String> SplitName(String fullName) {
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
