// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:cheetah_netdisk/components/bottom_bar.dart';
import 'package:cheetah_netdisk/components/file_tree.dart';
import 'package:cheetah_netdisk/components/mkdir_pop.dart';
import 'package:cheetah_netdisk/components/file_task_pop.dart';
import 'package:cheetah_netdisk/components/toast.dart';
import 'package:cheetah_netdisk/components/upload_floating.dart';
import 'package:cheetah_netdisk/controller/file_controller.dart';
import 'package:get/get.dart';

import '../../conf/const.dart';
import '../../conf/navi.dart';
import '../../controller/trans_controller.dart';

class FilePage extends GetView<FileController> {
  // FilePage({Key? key, required this.tc}) : super(key: key);
  // TransController tc;

  //FilePage({Key? key}) : super(key: key);
  // 检测退出逻辑
  DateTime lastPopTime = DateTime.now();

  FilePage({super.key});

  @override
  Widget build(BuildContext context) {
    TransController tc = Get.find<TransController>(tag: tcPerTag);
    print('file page tc: ${tc.hashCode}');
    
    PreferredSizeWidget _getAppBar(FileController fc) {
      // 后退按钮
      Widget leading = IconButton(
        onPressed: () {
          fc.back();
        },
        icon: Icon(
          Icons.arrow_back,
          color: Colors.white,
          size: 30,
        ),
      );
      return AppBar(
        leading: fc.isRoot() ? null : leading,
        title: Text(fc.curName),
        actions: [
          IconButton(
              onPressed: () {
                MkdirPop().showPop(fc);
              },
              icon: Icon(Icons.control_point)),
          IconButton(
              onPressed: () {
                if (fc.taskMap.isEmpty) {
                  MsgToast().customeToast('请先选择要操作的文件');
                  return;
                }
                FileTaskPop().showPop(fc, tc);
              },
              icon: Icon(Icons.keyboard_control)),
        ],
      );
    }

    return GetBuilder<FileController>(
      init: Get.find<FileController>(tag: fcPerTag),
      builder: (controller) {
        return WillPopScope(
            // TODO 退出逻辑
            onWillPop: () async {
              // 根目录执行退出app逻辑
              if (controller.isRoot()) {
                if (DateTime.now().difference(lastPopTime) >
                        Duration(seconds: 1)) {
                  lastPopTime = DateTime.now();

                  MsgToast().customeToast("再按一次退出");
                  return Future.value(false);
                } else {
                  lastPopTime = DateTime.now();
                  // 退出app
                  return Future.value(true);
                }
              }
              controller.back();
              return Future(() => false);
            },
            child: Scaffold(
              // 首页则无后退符号
              appBar: _getAppBar(controller),
              floatingActionButton: UploadFloating(tc: tc),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              body: FileTree(
                select: true,
                fc: controller,
              ),
              bottomNavigationBar: BottomBar(
                index: filePageIndex,
              ),
            ));
      },
    );
  }
}
