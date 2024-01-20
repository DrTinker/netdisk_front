import 'package:cheetah_netdisk/components/toast.dart';
import 'package:cheetah_netdisk/controller/user_controller.dart';
import 'package:cheetah_netdisk/helper/storage.dart';
import 'package:get/get.dart';

import '../conf/const.dart';

loginCheck(String? cur) async{
  // 无需登录的页面
  if (loginPassMap.containsKey(cur)) {
    return;
  }
  // 全局map中查看登录态
  var store = SyncStorage();
  bool flag = store.hasKey(userToken);
  // 已经登录则放行
  if (flag) {
    // // 如果是login页，则跳转file
    // if (cur == '/login') {
    //   Future.delayed(Duration.zero, (){
    //     if (flag) {Get.offAllNamed('/file');}
    //   });
    // }
    return;
  }
  
  // 未登录尝试读取磁盘存储的数据重新登录
  var ps = PersistentStorage();
  var aa = await ps.getKeys();
  // 磁盘未存储数据，说明没登陆过
  if (!await ps.hasKey(userEmail) || !await ps.hasKey(userPwd)) {
    if (cur != '/login') {
      Future.delayed(Duration.zero, (){
        if (!flag) {Get.offAllNamed('/login');}
      });
    }
    return;
  }
  // 存储了数据，说明登陆过，直接重新登录
  String email = await ps.getStorage(userEmail);
  String pwd = (await ps.getStorage(userPwd)).toString();
  // 登录后跳转
  bool login = await UserController.doLogin(email, pwd);
  // 尝试10次
  for (int i=0; i<10 && !login; i++) {
    login = await UserController.doLogin(email, pwd);
  }
  // 还未登录成功
  if (!login) {
    MsgToast().customeToast('暂时无法连接到服务器');
    Future.delayed(Duration.zero, (){
      if (!flag) {Get.offAllNamed('/login');}
    });
  }
  
  return;
}
