
import 'package:cheetah_netdisk/controller/trans_controller.dart';
import 'package:get/get.dart';

import '../conf/const.dart';

class TransBinding implements Bindings {
  @override
  void dependencies() {
    // file界面已经put过了，这里取得时同一个
    Get.lazyPut<TransController>(() => Get.find(tag : tcPerTag));
  }
}