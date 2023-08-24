import 'package:cheetah_netdesk/controller/file_controller.dart';
import 'package:get/get.dart';

import '../conf/const.dart';

class VideoBinding implements Bindings {
  @override
  void dependencies() {
    // file界面已经put过了，这里取得时同一个
    Get.lazyPut<FileController>(() => Get.find(tag : fcPerTag));
  }
}