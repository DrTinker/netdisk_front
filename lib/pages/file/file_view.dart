// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_learn/components/bottom_bar.dart';
import 'package:flutter_learn/components/file_tree.dart';
import 'package:flutter_learn/components/mkdir_pop.dart';
import 'package:flutter_learn/components/task_pop.dart';
import 'package:flutter_learn/components/toast.dart';
import 'package:flutter_learn/components/upload_floating.dart';
import 'package:flutter_learn/controller/file_controller.dart';
import 'package:get/get.dart';

import '../../conf/navi.dart';
import '../../controller/trans_controller.dart';

class FilePage extends GetView<FileController> {
  // FilePage({Key? key, required this.tc}) : super(key: key);
  // TransController tc;

  //FilePage({Key? key}) : super(key: key);
  // 检测退出逻辑
  DateTime lastPopTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
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
                TaskPop().showPop(fc);
              },
              icon: Icon(Icons.keyboard_control)),
        ],
      );
    }

    TransController tc = Get.find<TransController>();
    print('file page tc: ${tc.hashCode}');
    return GetBuilder<FileController>(
      //init: FileController(),
      builder: (controller) {
        return WillPopScope(
            // TODO 退出逻辑
            onWillPop: () async {
              // 根目录执行退出app逻辑
              if (controller.isRoot()) {
                if (lastPopTime == null ||
                    DateTime.now().difference(lastPopTime!) >
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
              floatingActionButton: UploadFloating(tc: tc,),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              body: FileTree(
                select: true,
                ext: '',
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
