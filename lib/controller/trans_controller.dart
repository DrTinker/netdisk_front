// ignore_for_file: unrelated_type_equality_checks

import 'dart:async';
import 'dart:io';

import '../models/file_model.dart';
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
import '../helper/file.dart';
import '../helper/parse.dart';
import '../helper/storage.dart';

// TODO 要解决的问题
// 1. 增加最大传输数量限制
// 2. 后台上传
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
    super.onInit();
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
  getMoreData(TransList objs) async {
    await objs.getMoreData();
    update();
  }

  // 加入工作队列
  addToUpload(
      String parentId, String uploadPath, List<PlatformFile> files) async {
    Set<TransObj> targets = {};
    for (var file in files) {
      print("filepath: ${file.path}");
      // 封装transobj
      TransObj obj = TransObj(file.name, file.extension, file.path, file.size,
          parentId, transProcess);
      obj.remotePath = uploadPath;
      // 设置传输状态为进行
      obj.running = processWait;
      // 加入队列
      uploadList.transList.add(obj);
      // 加入目标
      targets.add(obj);
    }
    update();
    startTrans(uploadFlag, false, targets: targets);
  }

  addToDownload(String parentId, String downloadPath, Map<String, FileObj> taskMap) async {
    Set<TransObj> targets = {};
    for (var id in taskMap.keys) {
      FileObj? file = taskMap[id];
      String fullName = '${file!.name}.${file.ext}';
      String path = await getDownloadDir(fullName, downloadPath);
      TransObj obj =
          TransObj(fullName, file.ext, path, file.size, parentId, transProcess);
      obj.fileUuid = file.uuid;
      obj.running = processWait;
      obj.remotePath = downloadPath;
      // 加入队列
      downloadList.transList.add(obj);
      // 加入目标
      targets.add(obj);
    }
    update();
    startTrans(downloadFlag, false, targets: targets);
  }

  // TODO 改造上传
  // 1. 开启传输isolate，主线程只负责选择文件，加入相应队列，每个传输对象分为4中状态
  // 2. 传输isolate中维护传输队列，每秒从主线程获取传输队列

  // 上传大文件
  uploadLargeFile(TransObj obj) async {
    bool flag = await initUploadPart(obj);
    if (!flag) {
      return;
    }
    await uploadPart(obj);
    if (obj.chunkList.length == obj.chunkCount) {
      await completeUploadPart(obj);
    }
  }

  // 下载大文件
  downloadLargeFile(TransObj obj) async {
    bool flag = await initDownloadPart(obj);
    if (!flag) {
      return;
    }
    // 轮询查看是否就绪
    // while (true) {
    //   String flag = readyWait;
    //   flag = await checkDownloadReady(obj);
    //   if (flag == readyAbort) {
    //     Get.snackbar("提示", "${obj.fullName}下载失败，请稍后重试");
    //     return;
    //   }
    //   if (flag == readyDone) {
    //     break;
    //   }
    //   Future.delayed(const Duration(seconds: 20));
    // }
    await downloadPart(obj);
    if (obj.chunkList.length == obj.chunkCount) {
      await completeDownloadPart(obj);
    }
  }

  bool flag = true;
  // 初始化分块上传
  Future<bool> initUploadPart(TransObj trans) async {
    // 设置开始时间
    trans.startTime = DateTime.now().microsecondsSinceEpoch;
    // 计算hash
    if (trans.hash == "") {
      await getFileHashByPath(trans.localPath)
          .then((value) => trans.hash = value);
    }
    // 查看文件是否存在
    File f = File(trans.localPath);
    bool dirBool = await f.exists();
    if (!dirBool) {
      Get.snackbar("提示", "${trans.fullName}已经不在原位置，请重新选择");
      flag = false;
      return flag;
    }
    Map<String, String> headers = {
      'Authorization': token,
    };
    Map<String, String> body = {
      'hash': trans.hash,
      'name': trans.fullName,
      'local_path': trans.localPath,
      'remote_path': trans.remotePath,
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
              trans.chunkList.add(chunk);
            }
          }
          return;
        }
        if (code == fileExistCode) {
          MsgToast().customeToast('文件已经存在，请勿重复上传');
          uploadList.transList.remove(trans);
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
        flag = false;
        return;
      },
    );
    return flag;
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
        if (trans.running != processRunning) {
          break;
        }
        x = (c - 1) * trans.chunkSize; // 已经上传的长度
        if (x < fileLength) {
          // 是否是最后一片了
          bool isLast = c < trans.chunkCount ? false : true;
          // 获取当前这一片的长度，最后一片可能没有设定的分片大小那么长，
          int _len = isLast ? fileLength - x : trans.chunkSize;
          // 设置文件指针
          sFile.setPositionSync(x);
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
              trans.running = processSuspend;
            },
          );
        }
      }
    } finally {
      sFile.close(); // 最后一定要关闭文件
    }
  }

  // 合并分块
  completeUploadPart(TransObj trans) async {
    if (trans.running != processRunning) {
      return;
    }
    trans.running = processWait;
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
            //trans.status = transSuccess;
          }
          update();
          // 发送通知
          MsgToast().customeToast('有文件上传成功了，快去看看吧');
          return;
        }
        if (code == fileHashErrCode) {
          Get.snackbar("提示", "文件${trans.fullName}可能已经损坏，无法上传");
          // 加入失败队列
          bool flag = uploadList.transList.remove(trans);
          if (flag) {
            uploadFailList.transList.add(trans);
            //trans.status = transFail;
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
    // var fileBytes = await trans.fileReadStream!.first;
    // file.hash = getFileHashByStream(fileBytes);
    await getFileHashByPath(trans.localPath)
        .then((value) => trans.hash = value);
    Map<String, dynamic> body = {
      'hash': trans.hash,
      'name': trans.fullName,
      'remote_path': trans.remotePath,
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
            // trans.status = transSuccess;
          }
          update();
          // 发送通知
          MsgToast().customeToast('有文件上传成功了，快去看看吧');
          return;
        }
        if (code == fileExistCode) {
          MsgToast().customeToast('文件已经存在，请勿重复上传');
          uploadList.transList.remove(trans);
          update();
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

  // 下载
  // 初始化分块下载
  Future<bool> initDownloadPart(TransObj trans) async {
    // 设置开始时间
    trans.startTime = DateTime.now().microsecondsSinceEpoch;
    Map<String, String> headers = {
      'Authorization': token,
    };
    Map<String, String> param = {
      "file_uuid": trans.fileUuid,
      'local_path': trans.localPath,
      'remote_path': trans.remotePath,
      'parent_uuid': trans.parentId,
      'download_id': trans.transID
    };
    bool flag = true;
    await NetWorkHelper.requestGet(
      initDownloadPartUrl,
      (data) {
        int code = data['code'];
        // 初始化成功
        if (code == httpSuccessCode) {
          trans.transID = data['download_id'];
          trans.chunkCount = data['chunk_count'];
          trans.chunkSize = data['chunk_size'];
          trans.hash = data['hash'];
          trans.url = data['url'];
          // 先清空
          trans.chunkList.clear();
          if (data['chunk_list'] != null) {
            for (var chunk in data['chunk_list']) {
              trans.chunkList.add(chunk);
            }
          }
          return;
        }
        // 发生错误
        MsgToast().customeToast('传输发生错误');
      },
      params: param,
      headers: headers,
      transform: JSONConvert.create(),
      error: (statusCode, error) {
        print(error.toString());
        flag = false;
        return;
      },
    );
    return flag;
  }

  // 查询文件就绪
  Future<String> checkDownloadReady(TransObj trans) async {
    Map<String, String> headers = {
      'Authorization': token,
    };
    Map<String, String> param = {'download_id': trans.transID};
    String res = "";
    await NetWorkHelper.requestGet(
      checkDownloadReadyUrl,
      (data) {
        int code = data['code'];
        // 初始化成功
        if (code == httpSuccessCode) {
          if (data['ready'] == "") {
            res = readyAbort;
            return;
          }
          res = data['ready'];
          return;
        }
      },
      params: param,
      headers: headers,
      transform: JSONConvert.create(),
      error: (statusCode, error) {
        print(error.toString());
      },
    );
    return res;
  }

  // 分块下载接口
  downloadPart(TransObj trans) async {
    // 查看还未上传的分片
    List<int> chunks = FindMissChunks(trans.chunkList, trans.chunkCount);
    int start = 0;
    int end = 0;
    for (var c in chunks) {
      if (trans.running != processRunning) {
        break;
      }
      start = (c - 1) * trans.chunkSize;
      // 从COS下载分片
      if (start < trans.totalSize) {
        // 是否是最后一片了
        bool isLast = c < trans.chunkCount ? false : true;
        // 获取当前这一片的长度，最后一片可能没有设定的分片大小那么长，
        int _len = isLast ? trans.totalSize - start : trans.chunkSize;
        // 确定end
        end = start + _len;
        // 修正start, 0-100 101-200 201-300
        start = (c == 1) ? start : start + 1;
      }
      // 分块地址
      String partDir = await getPartDir(trans.hash, trans.remotePath);
      String partPath = '$partDir/$c.${trans.ext}';
      // 记录curSize
      int tmpSize = trans.curSize;
      // 请求COS
      await NetWorkHelper.fileDownload(
        trans.url,
        (data) {
          print('chunk: $partPath 下载成功');
        },
        partPath, // fileBytes: fileBytes,
        range: 'bytes=$start-${end == 0 ? "" : end}',
        progress: (curSize, totalSize) {
          trans.curSize = tmpSize;
          // 进入发生变化时更新界面
          trans.curSize += curSize;
          // print('c: $c, 当前: ${trans.curSize}, 总计: $totalSize, cur: $curSize');
          update();
        },
        error: (statusCode, error) {
          // 出错暂停
          print(error);
          trans.running = processSuspend;
        },
      );
      // 再次检查状态，如果上一个请求执行失败则不进行写入
      if (trans.running != processRunning) {
        break;
      }
      // 通知服务端修改数据记录
      Map<String, String> param = {
        'download_id': trans.transID,
        'chunk_num': c.toString(),
      };
      Map<String, String> header = {
        'Authorization': token,
      };
      await NetWorkHelper.requestGet(
        downloadPartUrl,
        (data) {
          // 加入chunkList
          print('chunk: $c 写入成功');
          trans.chunkList.add(c);
        },
        headers: header,
        params: param,
        error: (statusCode, error) {
          print(error);
          trans.running = processSuspend;
        },
      );
    }
  }

  // 合并分块
  completeDownloadPart(TransObj trans) async {
    if (trans.running != processRunning) {
      return;
    }
    trans.running = processWait;
    // 合并文件
    String srcDir = await getPartDir(trans.hash, trans.remotePath);
    bool flag = await mergeFile(srcDir, trans.localPath);
    String hash = "";
    await getFileHashByPath(trans.localPath).then((value) => hash = value);
    if (!flag || trans.hash != hash) {
      Get.snackbar("提示", "文件${trans.fullName}可能已经损坏，请重新下载");
      // 加入失败队列
      bool flag1 = downloadList.transList.remove(trans);
      if (flag1) {
        downloadFailList.transList.add(trans);
      }
      return;
    }
    // 调用接口
    Map<String, String> headers = {
      'Authorization': token,
    };
    Map<String, String> param = {
      'download_id': trans.transID,
    };
    await NetWorkHelper.requestGet(
      completeDownloadPartUrl,
      (data) {
        int code = data['code'];
        // 合并成功
        if (code == httpSuccessCode) {
          // 设置进度为100
          trans.curSize = trans.totalSize;
          // 加入成功队列
          bool flag = downloadList.transList.remove(trans);
          if (flag) {
            downloadSuccessList.transList.add(trans);
            //trans.status = transSuccess;
          }
          update();
          // 发送通知
          MsgToast().customeToast('有文件下载成功了，快去看看吧');
          return;
        }
        // 发生错误
        MsgToast().customeToast('传输发生错误');
      },
      params: param,
      headers: headers,
      transform: JSONConvert.create(),
      error: (statusCode, error) {
        print(error.toString());
      },
    );
  }

  // 云存储直接下载
  downloadFile(TransObj trans) async {
    Map<String, String> param = {
      "file_uuid": trans.fileUuid,
      'local_path': trans.localPath,
      'remote_path': trans.remotePath,
      'parent_uuid': trans.parentId,
    };
    Map<String, String> headers = {
      'Authorization': token,
    };
    String sign = "";
    await NetWorkHelper.requestGet(
      downloadTotalUrl,
      (data) {
        int code = data['code'];
        // 合并成功
        if (code == httpSuccessCode) {
          // 获取预签名
          sign = data['file_token'];
          return;
        }
        // 发生错误
        MsgToast().customeToast('传输发生错误');
      },
      params: param,
      headers: headers,
      transform: JSONConvert.create(),
      error: (statusCode, error) {
        print(error.toString());
      },
    );
    trans.url = sign;
    // 直接从云存储下载
    await NetWorkHelper.fileDownload(
      sign,
      (data) {
        // 加入成功队列
        bool flag = downloadList.transList.remove(trans);
        if (flag) {
          downloadSuccessList.transList.add(trans);
        }
      },
      trans.localPath,
      progress: (curSize, totalSize) {
        // 进入发生变化时更新界面
        trans.curSize = curSize;
        update();
      },
      error: (statusCode, error) {
        print(error.toString());
      },
    );
  }

  // 删除记录
  delTransRecord(TransObj obj) async{
    String dir = await getPartDir(obj.hash, obj.remotePath);
    // 删除本地临时目录
    delDir(dir);
    Map<String, String> headers = {
      'Authorization': token,
    };
    Map<String, dynamic> body = {
      'trans_uuid': obj.transID,
    };

    NetWorkHelper.requestPost(
      transDelUrl,
      (data) {
        int code = data['code'];
        if (code != httpSuccessCode) {
          print('$data');
        }
      },
      body: body,
      headers: headers,
      transform: JSONConvert.create(),
      error: (statusCode, error) {
        print(error.toString());
      },
    );
  }

  // 滑动删除
  slideToDelTrans(List<TransObj> objList, int index) {
    TransObj obj = objList[index];
    // 先更改状态为finfish
    obj.running = processFinish;
    objList.removeAt(index);
    delTransRecord(obj);
    update();
  }

  // 暂停、继续和失败重传
  processHandler(TransObj obj, int mod, int status) {
    // print('runnintg: ${obj.running}, mod: $mod, status: $status');
    // fail状态
    if (status == transFail) {
      // 加入上传队列
      bool flag = uploadFailList.transList.remove(obj);
      if (flag) {
        obj.running = processWait;
        uploadList.transList.add(obj);
        // 删除trans记录
        delTransRecord(obj);
        // 重置transID
        obj.transID = "";
        // 异步开启传输
        startTrans(mod, false, target: obj);
      }
      update();
      return;
    }
    // process状态
    if (obj.running == processSuspend) {
      // 更改running状态
      obj.running = processWait;
      // 异步开启传输
      startTrans(mod, false, target: obj);
    } else if (obj.running == processRunning) {
      print("暂停");
      // 更改running状态
      obj.running = processSuspend;
    }
    update();
    return;
  }

  // 遍历工作队列，开始传输所有wait状态的trans对象
  // all 为true时，开始所有wait和suspend的，传all为true时target失效
  // all 为false时，开始所有wait状态的，此时传入target有效
  // target为要启动的目标对象transID，传入target时只会开始目标传输，不传则开始所有wait状态的
  startTrans(int mod, bool all,
      {Set<TransObj>? targets, TransObj? target}) async {
    for (var obj
        in mod == uploadFlag ? uploadList.transList : downloadList.transList) {
      // 为running一定跳过
      if (obj.running == processRunning) {
        continue;
      }
      if (!all) {
        // 忽略不为wait状态的
        if (obj.running != processWait) {
          continue;
        }
        // 只有一个target
        if (target != null && obj != target) {
          continue;
        }
        // 传targets且当前元素不为target，跳过
        if (targets != null && targets.isNotEmpty && !targets.contains(obj)) {
          continue;
        }
      }
      // 查看文件是否存在
      File f = File(obj.localPath);
      bool dirBool = await f.exists();
      if (!dirBool && mod == uploadFlag) {
        Get.snackbar("提示", "${obj.fullName}已经不在原位置，请重新选择");
        // 改为finish，无法再更改，等待用户手动删掉，或是再次进入app自动删掉
        obj.running = processFinish;
        continue;
      }
      // 更改状态
      obj.running = processRunning;
      // 开始传输
      if (obj.totalSize > largeMark) {
        print("大文件续传");
        if (mod == uploadFlag) {
          uploadLargeFile(obj);
        } else {
          downloadLargeFile(obj);
        }
      } else {
        print("小文件重传");
        if (mod == uploadFlag) {
          uploadFile(obj);
        } else {
          downloadFile(obj);
        }
      }
    }
  } // startTrans
}
