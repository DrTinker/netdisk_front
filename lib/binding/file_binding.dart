import 'package:flutter_learn/controller/file_controller.dart';
import 'package:get/get.dart';

import '../controller/trans_controller.dart';

class FileBinding implements Bindings {
  @override
  void dependencies() {
    // 用的时候才注册，controller为单例，fenix保证别的界面在binding时也是同一个controller
    Get.lazyPut<FileController>(() => FileController());
    Get.lazyPut<TransController>(() => TransController());
  }
}
