// ignore_for_file: unrelated_type_equality_checks

import 'dart:io';

import 'package:flutter_learn/helper/file.dart';
import 'package:flutter_learn/helper/md5.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_learn/conf/const.dart';
import 'package:flutter_learn/conf/url.dart';
import 'package:flutter_learn/helper/net.dart';
import 'package:flutter_learn/models/trans_model.dart';
import 'package:get/get.dart';

import '../components/toast.dart';
import '../conf/code.dart';
import '../helper/convert.dart';
import '../helper/parse.dart';
import '../helper/storage.dart';

// TODO 要解决的问题
// 1. 增加最大传输数量限制
// 2. 后台上传
// 3. 数据展示，工作队列中最新进行的排在前面
class TransController extends GetxController {
  TransList uploadList = TransList(uploadFlag, transProcess);
  TransList downloadList = TransList(downloadFlag, transProcess);

  TransList uploadFailList = TransList(uploadFlag, transFail);
  TransList downloadFailList = TransList(downloadFlag, transFail);

  TransList uploadSuccessList = TransList(uploadFlag, transSuccess);
  TransList downloadSuccessList = TransList(downloadFlag, transSuccess);

  // 用户登录
  String token = "";

  // TODO 增加最大传输数量限制

  @override
  void onInit() {
    // 尝试读取token和根目录，读不到直接返回，说明没登录
    var store = SyncStorage();
    if (!store.hasKey(userToken) && !store.hasKey(userStartDir)) {
      return;
    }
    if (token == "") {
      token = store.getStorage(userToken);
    }
    // 注入token
    uploadList.token = token;
    downloadList.token = token;
    uploadFailList.token = token;
    downloadFailList.token = token;
    uploadSuccessList.token = token;
    downloadSuccessList.token = token;
    // 获取数据
    getAllTransData();
    // TransObj t1 = TransObj('测试1', 'png', '/root/test/测试.png', 2000, '');
    // t1.setCurSize(200);

    // TransObj t2 = TransObj('测试2', 'png', '/root/test/测试.png', 2000, '');
    // t2.setCurSize(1000);
  }

  // 全部刷新，用于初始化
  getAllTransData() {
    uploadList.getTransList(false);
    downloadList.getTransList(false);
    uploadFailList.getTransList(false);
    downloadFailList.getTransList(false);
    uploadSuccessList.getTransList(false);
    downloadSuccessList.getTransList(false);
    update();
  }

  // 传入要刷新的列表序号
  getUploadTransList() {
    uploadList.getTransList(false);
    uploadFailList.getTransList(false);
    uploadSuccessList.getTransList(false);
    update();
  }

  getDownloadTransList() {
    downloadList.getTransList(false);
    downloadFailList.getTransList(false);
    downloadSuccessList.getTransList(false);
  }

  // 翻页
  getMoreData(int flag) {
    switch (flag) {
      case 0:
        uploadList.getMoreData();
      case 1:
        downloadList.getMoreData();
      case 2:
        uploadFailList.getMoreData();
      case 3:
        downloadFailList.getMoreData();
      case 4:
        uploadSuccessList.getMoreData();
      case 5:
        downloadSuccessList.getMoreData();
      default:
        print('error trans list idx');
    }
    update();
  }

  // 加入工作队列
  addToUpload(String parentId, List<PlatformFile> files) async {
    for (var file in files) {
      print("filepath: ${file.path}");
      // 封装transobj
      TransObj obj =
          TransObj(file.name, file.extension, file.path, file.size, parentId);
      // 获取文件流
      final fileReadStream = file.readStream;
      if (fileReadStream == null) {
        throw Exception('Cannot read file from null stream');
      }
      obj.fileReadStream = fileReadStream;
      // 设置传输状态为进行
      obj.running = true;
      // 加入队列
      uploadList.transList.add(obj);
      // 设置开始时间
      obj.startTime = DateTime.now().microsecondsSinceEpoch;
      if (file.size > largeMark) {
        print("大文件上传");
        uploadLargeFile(obj);     
      } else {
        uploadFile(obj);
      }
    }
    update();
  }

  // TODO 改造上传
  // 1. 开启传输isolate，主线程只负责选择文件，加入相应队列，每个传输对象分为4中状态
  // 2. 传输isolate中维护传输队列，每秒从主线程获取传输队列

  // 上传大文件
  uploadLargeFile(TransObj obj) async {
    await initUploadPart(obj);
    await uploadPart(obj);
    await completeUploadPart(obj);
  }

  // 初始化分块上传
  initUploadPart(TransObj trans) async {
    // 计算hash
    await getFileHashByPath(trans.localPath)
        .then((value) => trans.hash = value);
    Map<String, String> headers = {
      'Authorization': token,
    };
    Map<String, String> body = {
      'hash': trans.hash,
      'name': trans.fullName,
      'local_path': trans.localPath,
      'parent_uuid': trans.parentId,
      'size': (trans.totalSize).toString(),
      'upload_id': trans.transID
    };
    await NetWorkHelper.requestPost(
      initUploadPartUrl,
      (data) {
        int code = data['code'];
        // 秒传
        if (code == quickUploadCode) {
          // 设置进度为100
          trans.curSize = trans.totalSize;
          // 加入成功队列
          bool flag = uploadList.transList.remove(trans);
          if (flag) {
            uploadSuccessList.transList.add(trans);
          }
          MsgToast().customeToast('有文件上传成功了，快去看看吧');
          return;
        }
        // 非秒传，获取数据
        if (code == httpSuccessCode) {
          trans.transID = data['upload_id'];
          trans.chunkCount = data['chunk_count'];
          trans.chunkSize = data['chunk_size'];
          // 先清空
          trans.chunkList.clear();
          if (data['chunk_list'] != null) {
            for (var chunk in data['chunk_list']) {
              trans.chunkList.add(int.parse(chunk));
            }
          }
          return;
        }
        if (code==fileExistCode) {
          MsgToast().customeToast('文件已经存在，请勿重复上传');
          return;
        }
        // 发生错误
        MsgToast().customeToast('传输发生错误');
      },
      body: body,
      headers: headers,
      transform: JSONConvert.create(),
      error: (statusCode, error) {
        print(error.toString());
      },
    );
  }

  // 分块上传接口
  uploadPart(TransObj trans) async {
    // 查看还未上传的分片
    List<int> chunks = FindMissChunks(trans.chunkList, trans.chunkCount);
    File file = File(trans.localPath);
    var sFile = await file.open();
    try {
      int fileLength = sFile.lengthSync(); // 获取文件长度
      int x = 0;
      for (var c in chunks) {
        x = (c - 1) * trans.chunkSize; // 已经上传的长度
        if (x < fileLength) {
          // 是否是最后一片了
          bool isLast = c < trans.chunkCount ? false : true;
          // 获取当前这一片的长度，最后一片可能没有设定的分片大小那么长，
          int _len = isLast ? fileLength - x : trans.chunkSize;
          // 获取一片
          List<int> postData = sFile.readSync(_len).toList();
          //print("c: $c, isLast: $isLast, count: ${trans.chunkCount }, _len:$_len, len:${postData.length}");
          // 执行上传
          Map<String, dynamic> body = {
            'files': postData,
            'upload_id': trans.transID,
            'chunk_num': c,
          };
          // 记录curSize
          int tmpSize = trans.curSize;
          // 异步上传所有分片
          await NetWorkHelper.fileUplod(
            uploadPartUrl,
            token,
            (data) {
              int code = data['code'];
              // 传输成功
              if (code == httpSuccessCode) {
                // 加入chunkList
                trans.chunkList.add(c);
              }
            },
            trans,
            body: body,
            // fileBytes: fileBytes,
            progress: (curSize, totalSize) {
              trans.curSize = tmpSize;
              // 进入发生变化时更新界面
              trans.curSize += curSize;
              // print('c: $c, 当前: ${trans.curSize}, 总计: $totalSize, cur: $curSize');
              update();
            },
            transform: JSONConvert.create(),
            error: (statusCode, error) {
              print(error);
            },
          );
        }
      }
    } finally {
      sFile.close(); // 最后一定要关闭文件
    }
  }

  // 合并分块
  completeUploadPart(TransObj trans) async{
    while (trans.chunkCount>trans.chunkList.length) {
      print('还未完成 ${trans.chunkList}');
    }
    Map<String, String> headers = {
      'Authorization': token,
    };
    Map<String, dynamic> body = {
      'upload_id': trans.transID,
    };
    await NetWorkHelper.requestPost(
      completeUploadPartUrl,
      (data) {
        int code = data['code'];
        // 合并成功
        if (code == httpSuccessCode) {
          // 设置进度为100
          trans.curSize = trans.totalSize;
          // 加入成功队列
          bool flag = uploadList.transList.remove(trans);
          if (flag) {
            uploadSuccessList.transList.add(trans);
          }
          update();
          // 发送通知
          MsgToast().customeToast('有文件上传成功了，快去看看吧');
          return;
        }
        if (code==fileHashErrCode) {
          Get.snackbar("提示", "文件${trans.fullName}可能已经损坏，无法上传");
          // 加入失败队列
          bool flag = uploadList.transList.remove(trans);
          if (flag) {
            uploadFailList.transList.add(trans);
          }
          update();
          return;
        }
        // 发生错误
        MsgToast().customeToast('传输发生错误');
      },
      body: body,
      headers: headers,
      transform: JSONConvert.create(),
      error: (statusCode, error) {
        print(error.toString());
      },
    );
  }

  // 普通上传接口
  uploadFile(TransObj trans) async {
    // TODO 查看原因 直接读取byte数组导致文件损坏
    // 计算hash值，为了减少文件磁盘IO，hash值推迟到此时计算
    var fileBytes = await trans.fileReadStream!.first;
    // file.hash = getFileHashByStream(fileBytes);
    await getFileHashByPath(trans.localPath)
        .then((value) => trans.hash = value);
    Map<String, dynamic> body = {
      'files': fileBytes,
      'hash': trans.hash,
      'name': trans.fullName,
      'parent_uuid': trans.parentId,
    };
    await NetWorkHelper.fileUplod(
      uploadUrl,
      token,
      (data) {
        int code = data['code'];
        // 秒传或传输成功
        if (code == quickUploadCode || code == httpSuccessCode) {
          // 设置进度为100
          trans.curSize = trans.totalSize;
          // 加入成功队列
          bool flag = uploadList.transList.remove(trans);
          if (flag) {
            uploadSuccessList.transList.add(trans);
          }
          update();
          // 发送通知
          MsgToast().customeToast('有文件上传成功了，快去看看吧');
          return;
        }
        if (code==fileExistCode) {
          MsgToast().customeToast('文件已经存在，请勿重复上传');
          return;
        }
        // 发生错误
        MsgToast().customeToast('传输发生错误');
      },
      trans,
      body: body,
      // fileBytes: fileBytes,
      progress: (curSize, totalSize) {
        // 进入发生变化时更新界面
        trans.curSize = curSize;
        update();
      },
      transform: JSONConvert.create(),
      error: (statusCode, error) {
        MsgToast().serverErrToast();
        return;
      },
    );
  }
}
