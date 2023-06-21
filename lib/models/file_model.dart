import 'package:flutter_learn/conf/const.dart';

class File {
  String uuid;
  String userUuid;
  String ext;
  String name;
  String createdAt;
  String updatedAt;
  String icon;

  // 构造函数
  File ({required this.uuid, required this.userUuid, 
  required this.ext, required this.name, required this.createdAt, 
  required this.updatedAt, required this.icon});

  // 通过map构造
  static File fromMap(Map file) {
    String icon = 'assets/images/nodata.png';
    if (iconMap.containsKey(file['Ext'])) {
      icon = iconMap[file['Ext']]!;
    }
    return File (
      uuid: file['Uuid']!,
      userUuid: file['User_Uuid']!,
      ext: file['Ext']!,
      name: file['Name']!,
      createdAt: file['CreatedAt']!,
      updatedAt: file['UpdatedAt']!,
      icon: icon,
    );
  }
}