List<String> SplitName(String fullName) {
  List<String> res = [];
  var names = fullName.split('.');
  // 可能有文件名称为aa.aa.txt
  if (names.length==0) {
    return res;
  }
  String ext = names[names.length-1];
  String name = "";
  for (var i=0; i<names.length-1; i++) {
    name += names[i];
  }
  res.add(name); res.add(ext);
  return res;
}