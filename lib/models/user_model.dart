
import 'package:flutter/material.dart';

class UserObj {
  String userID="";
  String userName = "";
  String email = "";
  String phone = "";
  int level = 0;
  String startID = "";
  int nowVolume = 0;
  int totalVolume = 0;
  Widget avatar;
  // 构造函数
  UserObj(
      {required this.userID,
      required this.userName,
      required this.email,
      required this.phone,
      required this.level,
      required this.startID,
      required this.nowVolume,
      required this.totalVolume,
      required this.avatar});

  // 通过map构造
  static UserObj fromMap(Map user) {
    Widget icon = Image.asset('assets/random/qq.jpg', height: 60, width: 60,);
    Widget avatar = ClipOval(child: icon,);
    return UserObj(
      userID: user['Uuid']!,
      userName: user['Name']!,
      email: user['Email']!,
      phone: user['Phone']!,
      level: user['Level']!,
      startID: user['Start_Uuid'],
      nowVolume: user['Now_Volume']!,
      totalVolume: user['Total_Volume']!,
      avatar: avatar,
    );
  }

  static UserObj fromInfoMap(Map user) {
    Widget icon = Image.asset('assets/random/qq.jpg', height: 60, width: 60,);
    Widget avatar = ClipOval(child: icon,);
    return UserObj(
      userID: user['Uuid'] ?? "",
      userName: user['Name']?? "",
      email: user['Email']?? "",
      phone: user['Phone']?? "",
      level: user['Level']?? 0,
      startID: user['Start_Uuid']?? "",
      nowVolume: user['Now_Volume']?? 0,
      totalVolume: user['Total_Volume']?? 0,
      avatar: avatar,
    );
  }
}