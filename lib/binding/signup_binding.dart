
import 'package:cheetah_netdesk/controller/user_controller.dart';
import 'package:get/get.dart';

import '../conf/const.dart';

class SignUpBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserController>(() => UserController());
  }
}