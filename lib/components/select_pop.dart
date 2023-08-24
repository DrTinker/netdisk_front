// ignore_for_file: must_be_immutable, no_logic_in_create_state

import 'package:flutter/material.dart';
import 'package:cheetah_netdesk/components/file_tree.dart';
import 'package:cheetah_netdesk/components/mkdir_pop.dart';
import 'package:cheetah_netdesk/conf/const.dart';
import 'package:cheetah_netdesk/helper/convert.dart';
import 'package:get/get.dart';

import '../controller/file_controller.dart';

class SelectPopContent extends StatefulWidget {
  SelectPopContent({super.key, required this.taskFC, required this.outerFC, required this.index});
  FileController taskFC;
  FileController outerFC;

  int index;
  @override
  State<SelectPopContent> createState() =>
      _SelectPopContentState(taskFC: taskFC, outerFC: outerFC, index: index);
}

class _SelectPopContentState extends State<SelectPopContent> {
  _SelectPopContentState({required this.taskFC, required this.outerFC, required this.index});
  FileController taskFC;
  FileController outerFC;

  int index;

  PreferredSizeWidget _getAppBar() {
    // 后退按钮
    Widget leading = IconButton(
      onPressed: () {
        taskFC.back();
      },
      icon: const Icon(
        Icons.arrow_back,
        color: Colors.black,
        size: 30,
      ),
    );
    Widget close = IconButton(
      onPressed: () {
        Get.back();
      },
      icon: const Icon(
        Icons.close,
        color: Colors.black,
        size: 30,
      ),
    );
    return AppBar(
      backgroundColor: Colors.white,
      leading: taskFC.isRoot() ? null : leading,
      title: Text(taskFC.curName),
      actions: [close],
    );
  }

  Widget _getBottomBar() {
    return BottomNavigationBar(items: [
      BottomNavigationBarItem(
        label: "",
        icon: ElevatedButton(
          style: ButtonStyle(
              // 设置圆角
              shape: MaterialStateProperty.all(const StadiumBorder(
                  side: BorderSide(style: BorderStyle.none)))),
          child: Text('创建'),
          onPressed: () {
            MkdirPop().showPop(taskFC);
          },
        ),
      ),
      BottomNavigationBarItem(
        label: "",
        icon: ElevatedButton(
          style: ButtonStyle(
              // 设置圆角
              shape: MaterialStateProperty.all(const StadiumBorder(
                  side: BorderSide(style: BorderStyle.none)))),
          child: Text('至此路径下'),
          onPressed: () async{
            // 关闭弹出层
            Get.back();
            // dotask一定要在clear前完成
            // 执行任务
            if (index==uploadCode) {
              String uploadPath = taskFC.getNameListAsPath();
              outerFC.setUpload(taskFC.curDir, uploadPath);
            } else {
              await taskFC.doTask(index);
            }
            // 清空外层taskMap
            outerFC.clearTaskMap();
            
          },
        ),
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FileController>(
      // global置为false可以确保绑定的是新创建的controller，否则默认true是绑定的是全局注册的controller
      global: false,
      init: taskFC,
      builder: (controller) {
        return Scaffold(
          appBar: _getAppBar(),
          body: FileTree(
            select: false,
            exts: const ['folder'],
            fc: controller,
          ),
          bottomNavigationBar: _getBottomBar(),
        );
      },
    );
  }
}

class SelectPop {
  showPop(FileController fc, int task) {
    // 弹出
    FileController tmp = deepCopyFC(fc);
    // print('tmp==fc? ${tmp==fc}');
    Get.bottomSheet(
      Container(
        height: 700,
        color: Colors.white,
        child: SelectPopContent(
          taskFC: tmp,
          outerFC: fc,
          index: task,
        ),
      ),
      isDismissible: false,
    );
  }
}
