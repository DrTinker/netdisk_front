
import 'package:cheetah_netdesk/controller/share_controller.dart';
import 'package:cheetah_netdesk/controller/user_controller.dart';
import 'package:get/get.dart';

import '../conf/const.dart';
import '../controller/trans_controller.dart';

class ShareBinding implements Bindings {
  @override
  void dependencies() {
    // 创建sc
    Get.lazyPut<ShareController>(() => ShareController());
    // file界面已经put过了，这里取得时同一个
    Get.lazyPut<TransController>(() => Get.find(tag : tcPerTag));
  }
}