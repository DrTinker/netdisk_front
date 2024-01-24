import 'dart:io';
import 'dart:math';

import 'package:cheetah_netdisk/conf/file.dart';
import 'package:get/get_connect/sockets/src/socket_notifier.dart';
import 'package:path_provider/path_provider.dart';

// 切分文件，传入chunkNum(第几个分块,从1开始) and chunkSize(分块大小)
// 返回文件部分byte数组
Future<List<int>> SplitFile(String path, int chunkNum, int chunkSize) async {
  File file = File(path);
  var sFile = await file.open();
  try {
    int fileLength = sFile.lengthSync(); // 获取文件长度
    int x = chunkNum - 1 * chunkSize; // 已经上传的长度

    if (x < fileLength) {
      // 是否是最后一片了
      bool isLast = fileLength - x >= chunkSize ? false : true;
      // 获取当前这一片的长度，最后一片可能没有设定的分片大小那么长，
      int _len = isLast ? fileLength - x : chunkSize;
      // 获取一片
      List<int> postData = sFile.readSync(_len).toList();
      return postData;
    }
  } finally {
    sFile.close(); // 最后一定要关闭文件
  }
  return [];
}

createDir(String path) async {
  var dir = Directory(path);
  var exist = dir.existsSync();
  if (!exist) {
    var result = await dir.create(recursive: true);
    print('create: $result');
  }
}

// 获取分片保存地址
Future<String> getPartDir(String hash, String path) async {
  Directory? dir = await getExternalStorageDirectory();
  // 非安卓平台获取下载路径
  dir ??= await getDownloadsDirectory();
  // 不存在则创建
  createDir('${dir!.path}/$path/$hash');
  return '${dir.path}/$path/$hash';
}

// 获取文件下载保存地址
Future<String> getDownloadDir(String fullName, String path) async {
  // 安卓获取外部存储路径
  Directory? dir = await getExternalStorageDirectory();
  // 非安卓平台获取下载路径
  dir ??= await getDownloadsDirectory();
  return '${dir!.path}/$path/$fullName';
}

Future<bool> mergeFile(String srcDir, String desFile) async {
  print("src: $srcDir, des: $desFile");
  try {
    Directory src = Directory(srcDir);
    // 目录不存在时报错退出
    bool flag = await src.exists();
    if (!flag) {
      print('$srcDir do not exist');
      return false;
    }
    // 不存在时创建目标文件
    File des = File(desFile);
    // 存在则先删除再创建(覆盖)
    bool exist = des.existsSync();
    if (exist) {
      des.deleteSync();
    }
    des.createSync(recursive: true);
    // 获取所有子文件 这里按照数字顺序获取分片文件
    List<FileSystemEntity> chunks = src.listSync().toList();
    print("len: ${chunks.length}");
    // 追加写入文件
    for (var c in chunks) {
      List<int> data = [];
      if (c is File) data = (c as File).readAsBytesSync().toList();
      des.writeAsBytesSync(data, mode: FileMode.append);
    }
    // 删除src
    src.delete(recursive: true);
    print("deslen: ${await des.length()}");
  } catch (e) {
    print("MergeFile: $e");
    return false;
  }
  return true;
}

delDir(String dir) {
  Directory dirObj = Directory(dir);
  // 目录不存在时报错退出
  bool flag = dirObj.existsSync();
  if (flag) {
    // 删除src
    dirObj.delete(recursive: true);
  }
}

bool fileExist(String path) {
  bool flag = false;
  try {
    File file = File(path);
    flag = file.existsSync();
  } catch (e) {
    print("$e");
  }
  return flag;
}

String getRandomPicPath() {
  int idx = Random().nextInt(randomPicList.length - 1);
  return randomPicList[idx];
}