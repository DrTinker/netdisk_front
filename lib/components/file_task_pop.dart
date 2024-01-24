// ignore_for_file: must_be_immutable, no_logic_in_create_state, constant_pattern_never_matches_value_type

import 'package:flutter/material.dart';
import 'package:cheetah_netdisk/components/rename_pop.dart';
import 'package:cheetah_netdisk/components/select_pop.dart';
import 'package:cheetah_netdisk/components/share_pop.dart';
import 'package:cheetah_netdisk/components/toast.dart';
import 'package:cheetah_netdisk/conf/const.dart';
import 'package:cheetah_netdisk/controller/file_controller.dart';
import 'package:cheetah_netdisk/controller/trans_controller.dart';
import 'package:cheetah_netdisk/models/share_model.dart';
import 'package:get/get.dart';

import '../models/file_model.dart';

class FileTaskPopContent extends StatefulWidget {
  FileTaskPopContent({super.key, required this.fc, required this.tc});
  FileController fc;
  TransController tc;
  @override
  State<FileTaskPopContent> createState() => _FileTaskPopContentState(fc: fc, tc: tc);
}

class _FileTaskPopContentState extends State<FileTaskPopContent> {
  _FileTaskPopContentState({required this.fc, required this.tc});
  FileController fc;
  TransController tc;

  List<Widget> _getList() {
    List<Widget> list = [];
    list.add(
      ListTile(title: Text('共选择${fc.taskMap.length}个文件'),)
    );
    int len = taskTypeList.length;
    // 超过一个不许重命名和分享
    if (fc.taskMap.length>1) {
      len -= 2;
    }
    // 包含文件夹不能下载
    bool flag = false;
    fc.taskMap.forEach((key, value) {
      if (value.ext == 'folder') {
        flag = true;
      }
    });
    for (var i = 0; i < len; i++) {
      // 包含文件夹跳过下载按钮渲染
      if (flag && i==3) {
        continue;
      }
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
        return () async{
          String downloadPath = fc.getNameListAsPath();
          await tc.addToDownload(fc.curDir, downloadPath, fc.taskMap);
          fc.clearTaskMap();
          Get.back();
        };
      case shareCode:
        return () async{
          Get.back();
          // 获取file
          FileObj? file;
          if (fc.taskMap.isEmpty) {
            MsgToast().serverErrToast();
            return;
          }
          // 只有一个
          fc.taskMap.forEach((key, value) {
            file = value;
          },);
          // 创建Share
          String fullName = '${file!.name}.${file!.ext}';
          ShareObj share = ShareObj(file!.userID, file!.fileID, fullName);
          SharePop().showPop(share, fc.token);
          // 清理task
          fc.clearTaskMap();
        };
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

class FileTaskPop {
  showPop(FileController fc, TransController tc) {
    Get.bottomSheet(
      Container(
        height: 500,
        color: Colors.white,
        child: FileTaskPopContent(fc: fc, tc: tc,),
      ),
      backgroundColor: Colors.white,
    );
  }
}
