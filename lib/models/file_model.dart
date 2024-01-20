import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cheetah_netdisk/conf/const.dart';

import '../conf/file.dart';

class FileObj {
  String uuid;
  String userUuid;
  String ext;
  String name;
  int size;
  String hash;
  String createdAt;
  String updatedAt;
  Widget icon;

  // 构造函数
  FileObj(
      {required this.uuid,
      required this.userUuid,
      required this.size,
      required this.ext,
      required this.name,
      required this.hash,
      required this.createdAt,
      required this.updatedAt,
      required this.icon});

  // 通过map构造
  static FileObj fromMap(Map file) {
    Widget icon = Image.asset('assets/icons/nodata.png', width: standardPicSize, height: standardPicSize);
    if (file['Thumbnail'] != "") {
      icon = CachedNetworkImage(
        width: standardPicSize, height: standardPicSize,
        imageUrl: file['Thumbnail'],
        placeholder: (context, url) => Image.asset('assets/icons/nodata.png', width: standardPicSize, height: standardPicSize),
        errorWidget: (context, url, error) => Image.asset('assets/icons/nodata.png', width: standardPicSize, height: standardPicSize),
      );
    } else if (iconMap.containsKey(file['Ext'])) {
      icon = Image.asset(iconMap[file['Ext']]!, width: standardPicSize, height: standardPicSize,);
    }
    return FileObj(
      uuid: file['Uuid']!,
      userUuid: file['User_Uuid']!,
      ext: file['Ext']!,
      name: file['Name']!,
      size: file['Size']!,
      hash: file['Hash'],
      createdAt: file['CreatedAt']!,
      updatedAt: file['UpdatedAt']!,
      icon: icon,
    );
  }
}
