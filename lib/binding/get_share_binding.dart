import 'package:cheetah_netdisk/conf/const.dart';
import 'package:cheetah_netdisk/controller/file_controller.dart';
import 'package:cheetah_netdisk/controller/share_controller.dart';
import 'package:cheetah_netdisk/controller/trans_controller.dart';
import 'package:get/get.dart';


class GetShareBinding implements Bindings {
  @override
  void dependencies() {
    // 获取sc
    Get.lazyPut<ShareController>(() => ShareController());
    Get.lazyPut<TransController>(() => Get.find(tag: tcPerTag));
    Get.lazyPut<FileController>(() => Get.find(tag: fcPerTag));
  }
}