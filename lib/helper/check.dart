import 'package:flutter_learn/helper/storage.dart';
import 'package:get/get.dart';

import '../conf/const.dart';

loginCheck(String? cur) {
  // 无需登录的页面
  if (loginPassMap.containsKey(cur)) {
    return;
  }
  var store = SyncStorage();
  bool flag = false;
  flag = flag || store.hasKey(userInfo);
  flag = flag || store.hasKey(userToken);
  // 未登录则跳回登录页
  Future.delayed(Duration.zero, (){
    if (!flag) {Get.offAllNamed('/login');}
  });
  
  return;
}
