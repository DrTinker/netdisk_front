import 'package:cheetah_netdisk/controller/file_controller.dart';
import 'package:cheetah_netdisk/controller/user_controller.dart';
import 'package:get/get.dart';

import '../conf/const.dart';
import '../controller/trans_controller.dart';

class FileBinding implements Bindings {
  @override
  void dependencies() {
    // 进入app时在filepage先把fc和tc初始化，并设置为永久存在
    Get.put<FileController>(FileController(), permanent: true, tag: fcPerTag);
    Get.put<TransController>(TransController(), permanent: true, tag: tcPerTag);
  }
}
