import 'package:flutter/material.dart';
import 'package:cheetah_netdisk/conf/const.dart';
import 'package:cheetah_netdisk/helper/parse.dart';

import '../conf/file.dart';

class ShareObj {
  String uuid = "";
  String userUuid = "";
  String fileUuid = "";
  String fullName = "";
  String? code;
  String? expireAt;
  int status=0;
  String createdAt = "";
  String updatedAt = "";
  Widget? icon;

  static ShareObj fromMap(Map share) {
    String uuid = share['Uuid'];
    String fullName = share['Fullname'];
    String user = share['User_Uuid'];
    String file = share['User_File_Uuid'];
    String code = share['Code'];
    String expire = share['Expire_Time'];
    ShareObj obj = ShareObj(user, file, fullName);
    obj.code = code;
    obj.uuid = uuid;
    obj.expireAt = expire;
    obj.createdAt = share['CreatedAt']!;
    obj.updatedAt = share['UpdatedAt']!;
    if (share.containsKey('Status')) {
      obj.status = share['Status'];
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
    userUuid = user;
    fileUuid = file;
  }
}