// ignore_for_file: prefer_initializing_formals

import 'package:flutter_learn/conf/const.dart';
import 'package:flutter_learn/helper/storage.dart';

class TransObj {
  String id="";
  String icon="";
  String fullName="";
  String ext="";
  String hash = "";
  String localPath = ""; // 本地文件地址
  String fileKey = ""; // 云端地址
  String parentId = "";
  int totalSize=0; // 文件总大小
  int curSize=0; // 已上传大小
  int startTime=0;
  TransPart? partInfo; // 分块上传信息
  Stream<List<int>>? fileReadStream;
  
  TransObj(String fullName, String? ext, String? local, int totalSize, String? parentId) {
    icon = 'assets/images/nodata.png';
    this.fullName = fullName;
    ext = ext;
    if (iconMap.containsKey(ext)) {
      icon = iconMap[ext]!;
    }
    localPath = local!;
    // 默认在根路径下
    if (parentId!=null) {
      this.parentId = parentId;
    } else {
      var store = SyncStorage();
      if (store.hasKey(userStartDir)) {
        parentId = store.getStorage(userStartDir);
      }
    }
    
    // 初始化时先置为0，到发请求时再计算
    this.totalSize = totalSize;
    startTime = DateTime.now().second;
  }

  setCurSize(int value) {
    curSize = value;
  }

  setTotalSize(int value) {
    totalSize = value;
  }

  setReadStream(Stream<List<int>> reader) {
    fileReadStream = reader;
  }
}

class TransPart {
  int chunkSize=0;
  int chunkCount=0;
  List<int> chunkList=[]; // 已上传的分块列表
  String uploadID="";

  TransPart(int size, int count, List<int>? list, String id) {
    chunkSize = size;
    chunkCount = count;
    uploadID = id;
    chunkList = list!;
  }
}