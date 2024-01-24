import 'package:flutter/material.dart';
import 'package:cheetah_netdisk/conf/const.dart';
import 'package:cheetah_netdisk/helper/parse.dart';

import '../conf/file.dart';

class ShareObj {
  String shareID = "";
  String userID = "";
  String fileID = "";
  String fullName = "";
  String? code;
  String? expireAt;
  int status=0;
  String createdAt = "";
  String updatedAt = "";
  Widget? icon;

  static ShareObj fromMap(Map share) {
    String uuid = share['shareID'];
    String fullName = share['fullname'];
    String user = share['userID'];
    String file = share['fileID'];
    String code = share['code'];
    String expire = share['expireTime'];
    ShareObj obj = ShareObj(user, file, fullName);
    obj.code = code;
    obj.shareID = uuid;
    obj.expireAt = expire;
    obj.createdAt = share['createdAt']!;
    obj.updatedAt = share['updatedAt']!;
    if (share.containsKey('status')) {
      obj.status = share['status'];
    }
    // 图标
    String ext = splitName(fullName)[1];
    Widget icon = Image.asset('assets/icons/nodata.png', width: standardPicSize, height: standardPicSize);
    if (iconMap.containsKey(ext)) {
      icon = Image.asset(iconMap[ext]!, width: standardPicSize, height: standardPicSize,);
    }
    obj.icon = icon;
    return obj;
  }

  ShareObj(String user, file, this.fullName) {
    userID = user;
    fileID = file;
  }
}