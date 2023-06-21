// ignore_for_file: must_be_immutable, no_logic_in_create_state, constant_pattern_never_matches_value_type

import 'package:flutter/material.dart';
import 'package:flutter_learn/components/reaname_pop.dart';
import 'package:flutter_learn/components/select_pop.dart';
import 'package:flutter_learn/components/toast.dart';
import 'package:flutter_learn/conf/const.dart';
import 'package:flutter_learn/controller/file_controller.dart';
import 'package:get/get.dart';

class TaskPopContent extends StatefulWidget {
  TaskPopContent({super.key, required this.fc});
  FileController fc;
  @override
  State<TaskPopContent> createState() => _TaskPopContentState(fc: fc);
}

class _TaskPopContentState extends State<TaskPopContent> {
  _TaskPopContentState({required this.fc});
  FileController fc;

  List<Widget> _getList() {
    List<Widget> list = [];
    list.add(
      ListTile(title: Text('共选择${fc.taskMap.length}个文件'),)
    );
    int len = taskTypeList.length;
    // 超过一个不许重命名
    if (fc.taskMap.length>1) {
      len --;
    }
    for (var i = 0; i < len; i++) {
      list.add(ListTile(
        leading: taskIconList[i],
        title: Text(taskTypeList[i]),
        onTap: _getTaskHandler(i),
      ));
    }
    return list;
  }

  Function()? _getTaskHandler(int index) {
    // index写入fc
    switch(index) {
      case copyCode:
        return () {
          Get.back();
          //fc.storeDir();
          SelectPop().showPop(fc, index);
        };
      case moveCode:
        return () {
          Get.back();
          //fc.storeDir();
          SelectPop().showPop(fc, index);
        };
      case deleteCode:
        return () async{
          await fc.doTask(index);
          fc.clearTaskMap();
          Get.back();
        };
      case downloadCode:
        return (){};
      case shareCode:
        return (){};
      case renameCode:
        return (){
          Get.back();
          RenamePop().showPop(fc);
        };
      default:
        MsgToast().customeToast('操作类型错误');
        return (){};
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: _getList(),
    );
  }
}

class TaskPop {
  showPop(FileController fc) {
    Get.bottomSheet(
      Container(
        height: 500,
        color: Colors.white,
        child: TaskPopContent(fc: fc,),
      ),
      backgroundColor: Colors.white,
    );
  }
}
