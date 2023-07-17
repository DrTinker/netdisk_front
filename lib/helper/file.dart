import 'dart:io';

// 切分文件，传入chunkNum(第几个分块,从1开始) and chunkSize(分块大小)
// 返回文件部分byte数组
Future<List<int>> SplitFile(String path, int chunkNum, int chunkSize) async {
  File file = File(path);
  var sFile = await file.open();
  try {
    int fileLength = sFile.lengthSync(); // 获取文件长度
    int x = chunkNum-1 * chunkSize; // 已经上传的长度

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
