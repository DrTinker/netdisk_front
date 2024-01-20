import 'dart:async';
import 'dart:io';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';

import 'package:cheetah_netdisk/conf/const.dart';
import 'package:http/http.dart';

// 通过路径读取，用于大文件
Future<String> getFileHashByPath(String filePath) async {
  final file = File(filePath);
  final fileLength = file.lengthSync();

  final sFile = await file.open();
  try {
    final output = AccumulatorSink<Digest>();
    final input = md5.startChunkedConversion(output);
    int x = 0;
    const chunkSize = largeMark;
    while (x < fileLength) {
      final tmpLen = fileLength - x > chunkSize ? chunkSize : fileLength - x;
      input.add(sFile.readSync(tmpLen));
      x += tmpLen;
    }
    input.close();

    final hash = output.events.single;
    return hash.toString();
  } finally {
    unawaited(sFile.close());
  }
}

Future<String> getFileHashSimple(String filePath) async {
  final file = File(filePath);
  final fileLength = file.lengthSync();

  final fileBytes = file.readAsBytesSync().buffer.asUint8List();
  final hash = md5.convert(fileBytes.buffer.asUint8List()).toString();
  return hash;
}

String getFileHashByStream(List<int> fileBytes) {
  final hash = md5.convert(fileBytes).toString();
  return hash;
}