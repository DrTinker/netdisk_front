// ignore_for_file: prefer_initializing_formals

import 'package:flutter/material.dart';
import 'package:cheetah_netdisk/components/toast.dart';
import 'package:cheetah_netdisk/conf/const.dart';
import 'package:cheetah_netdisk/helper/storage.dart';

import '../conf/file.dart';
import '../conf/url.dart';
import '../helper/convert.dart';
import '../helper/net.dart';

class TransObj {
  // 基本信息
  String transID = ""; // 传输uuid
  String fileUuid = ""; // 文件file_uuid
  Widget? icon;
  String fullName = "";
  String ext = "";
  String hash = "";
  String localPath = ""; // 本地文件地址
  String remotePath=""; // 用户空间中的路径
  String fileKey = ""; // 云端地址
  String parentId = ""; // 父节点file_uuid
  int totalSize = 0; // 文件总大小
  int curSize = 0; // 已上传大小
  int startSize = 0; // 开始传输时的大小
  int startTime = 0;
  String url = ""; // cos下载路径
  // 状态
  // int status = transProcess;
  int running = processWait; // 新创建的trans对象均为wait
  // 分块上传
  int chunkSize = 0;
  int chunkCount = 0;
  List<int> chunkList = []; // 已上传的分块列表

  static TransObj fromMap(Map trans) {
    String fullName = trans['Name'] + "." + trans['Ext'];
    String ext = trans['Ext'];
    String local = trans['Local_Path'];
    int totalSize = trans['Size'];
    String parentId = trans['Parent_Uuid'];
    int status = trans['Status'];
    TransObj obj = TransObj(fullName, ext, local, totalSize, parentId, status);
    obj.transID = trans['Uuid'];
    obj.fileUuid = trans['File_Uuid'];
    obj.hash = trans['Hash'];
    obj.curSize = trans['CurSize'];
    obj.startSize = obj.curSize;
    obj.remotePath = trans['Remote_Path'];
    
    // 处理最后一个分片不满的情况
    if (obj.curSize > obj.totalSize) {
      obj.curSize = obj.totalSize;
    }
    obj.chunkSize = trans['ChunkSize'];
    if (trans['chunk_list'] != null) {
      for (var chunk in trans['ChunkList']) {
        obj.chunkList.add(int.parse(chunk));
      }
    }
    return obj;
  }

  TransObj(String fullName, String? ext, String? local, int? totalSize,
      String? parentId, int status) {
    icon = Image.asset('assets/icons/nodata.png', width: standardPicSize, height: standardPicSize);
    this.fullName = fullName;
    this.ext = ext!;
    if (iconMap.containsKey(ext)) {
      icon = Image.asset(iconMap[ext]!, width: standardPicSize, height: standardPicSize,);
    }
    localPath = local!;
    // 默认在根路径下
    if (parentId != null) {
      this.parentId = parentId;
    } else {
      var store = SyncStorage();
      if (store.hasKey(userStartDir)) {
        parentId = store.getStorage(userStartDir);
      }
    }
    // this.status = status;
    // 初始化时先置为0，到发请求时再计算
    this.totalSize = totalSize!;
  }
}

// TODO 优化为双向链表
class TransList {
  List<TransObj> transList = [];
  Set<String> _transSet = {};
  // 用于快速索引list中的对象，执行队列移动操作
  // Map<TransObj, int> indexMap = {};
  int page = 1;
  String token = "";
  int mod = 0; // 上传还是下载
  int status = 0; // 状态 进行 成功 失败

  TransList(int mod, int status) {
    this.mod = mod;
    this.status = status;
  }

  clearList() {
    transList.clear();
    _transSet.clear();
  }

  addTrans(TransObj transObj) {
    if (!_transSet.contains(transObj.transID)) {
      transList.add(transObj);
      _transSet.add(transObj.transID);
    }
  }

  bool removeTrans(TransObj transObj) {
    if (status == transProcess) {
      return transList.remove(transObj);
    }
    return transList.remove(transObj) && _transSet.remove(transObj.transID);
  }

  // 读取传输列表
  getTransList(bool append) async {
    Map<String, String> headers = {
      'Authorization': token,
    };
    Map<String, String> params = {
      'page': page.toString(),
      'isdown': mod.toString(),
      'status': status.toString(),
    };
    // 删除
    await NetWorkHelper.requestGet(
      transInfoUrl,
      (data) {
        var trans_list = data['trans_list'];
        // 刷新清空
        if (!append) {
          clearList();
          page = 1;
        }
        for (int i = 0; i < trans_list.length; i++) {
          TransObj transObj = TransObj.fromMap(trans_list[i]);
          // 不存在才加入, 解决刷新数据冲突问题
          if (!_transSet.contains(transObj.transID)) {
            addTrans(transObj);
          }
        }
      },
      params: params,
      headers: headers,
      transform: JSONConvert.create(),
    );
  }

  // 加载更多
  getMoreData() async {
    if (page <= 0) {
      return;
    }
    page = ((transList.length / defaultPageSize) + 1).toInt();
    print('getMoreData, page: $page');
    int preLen = transList.length;
    await getTransList(true);
    int curLen = transList.length;
    // 没有更多数据
    if (curLen == preLen) {
      MsgToast().customeToast('没有更多数据了');
    }
    return;
  }
}
