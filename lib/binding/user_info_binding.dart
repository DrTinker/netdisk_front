

import 'package:cheetah_netdesk/controller/file_controller.dart';
import 'package:cheetah_netdesk/controller/trans_controller.dart';
import 'package:get/get.dart';

import '../conf/const.dart';
import '../controller/user_controller.dart';

class UserInfoBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserController>(() => UserController());
    Get.lazyPut<TransController>(() => Get.find(tag : tcPerTag));
    Get.lazyPut<FileController>(() => Get.find(tag : fcPerTag));
  }
}