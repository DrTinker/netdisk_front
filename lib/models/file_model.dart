import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cheetah_netdisk/conf/const.dart';

import '../conf/file.dart';

class FileObj {
  String fileID;
  String userID;
  String ext;
  String name;
  int size;
  String hash;
  String createdAt;
  String updatedAt;
  Widget icon;

  // 构造函数
  FileObj(
      {required this.fileID,
      required this.userID,
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
    if (file['thumbnail'] != "") {
      icon = CachedNetworkImage(
        width: standardPicSize, height: standardPicSize,
        imageUrl: file['thumbnail'],
        placeholder: (context, url) => Image.asset('assets/icons/nodata.png', width: standardPicSize, height: standardPicSize),
        errorWidget: (context, url, error) => Image.asset('assets/icons/nodata.png', width: standardPicSize, height: standardPicSize),
      );
    } else if (iconMap.containsKey(file['ext'])) {
      icon = Image.asset(iconMap[file['ext']]!, width: standardPicSize, height: standardPicSize,);
    }
    return FileObj(
      fileID: file['fileID']!,
      userID: file['userID']!,
      ext: file['ext']!,
      name: file['name']!,
      size: file['size']!,
      hash: file['hash'],
      createdAt: file['createdAt']!,
      updatedAt: file['updatedAt']!,
      icon: icon,
    );
  }
}
