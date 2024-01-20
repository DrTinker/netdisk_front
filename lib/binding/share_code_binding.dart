import 'package:cheetah_netdisk/controller/share_controller.dart';
import 'package:get/get.dart';


class ShareCodeBinding implements Bindings {
  @override
  void dependencies() {
    // 获取sc
    Get.lazyPut<ShareController>(() => ShareController());
  }
}