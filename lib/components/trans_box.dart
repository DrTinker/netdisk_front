// ignore_for_file: no_logic_in_create_state, must_be_immutable, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:cheetah_netdisk/conf/const.dart';
import 'package:cheetah_netdisk/controller/trans_controller.dart';
import 'package:cheetah_netdisk/models/trans_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';

import '../helper/parse.dart';

class TransBox extends StatefulWidget {
  TransBox(
      {super.key,
      required this.tc,
      required this.index,
      required this.status,
      required this.flag});
  int index;
  int flag; // 上传下载标志
  int status; // 传输状态
  TransController tc;
  @override
  State<TransBox> createState() =>
      _TransBoxState(index: index, tc: tc, status: status, flag: flag);
}

class _TransBoxState extends State<TransBox> {
  _TransBoxState(
      {required this.tc,
      required this.index,
      required this.status,
      required this.flag});
  int index;
  int flag; // 上传下载标志
  int status; // 传输状态
  TransController tc;

  bool _isSelect = false;

  List<TransObj> objList = [];

  Widget _getTitle() {
    TransObj obj = objList[index];
    String fullName = "";
    if (obj.ext == 'folder') {
      fullName = obj.fullName;
    } else {
      fullName = obj.fullName;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          fullName,
          textAlign: TextAlign.left,
        ),
        SizedBox(
          height: 10,
        ),
        // 根据传输状态决定是否展示进度条
        status == transProcess
            ? SizedBox(
                height: 3,
                width: 200,
                child: LinearProgressIndicator(
                  value: obj.totalSize == 0 ? 0 : obj.curSize / obj.totalSize,
                  backgroundColor: Colors.grey,
                  valueColor: AlwaysStoppedAnimation(Colors.blue),
                ),
              )
            : SizedBox(
                height: 0,
              ),
        SizedBox(
          height: 5,
        ),
      ],
    );
  }

  Widget? _getSubTitle() {
    switch (status) {
      case transProcess:
        return _buildProcessSub();
      case transSuccess:
        return _buildSuccessSub();
      case transFail:
        return _buildFailSub();
      default:
        return null;
    }
  }

  Widget _buildProcessSub() {
    TransObj obj = objList[index];
    Widget sub;
    if (obj.running == processWait || obj.running == processSuspend) {
      sub = const Text('暂停下载');
    } else {
      sub = Text(parseSpeed(obj.curSize, obj.startSize, obj.startTime));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('${parseSize(obj.curSize)}/${parseSize(obj.totalSize)}'),
        sub,
      ],
    );
  }

  Widget _buildSuccessSub() {
    TransObj obj = objList[index];
    if (flag==downloadFlag) {
      return Text(obj.localPath);
    } 
    return Text('${parseSize(obj.totalSize)}  上传至: ${obj.remotePath}');
  }

  Widget _buildFailSub() {
    TransObj obj = objList[index];
    return Text(parseSize(obj.totalSize));
  }

  Widget? _buildNormalTrailing() {
    TransObj obj = objList[index];
    Widget? icon;
    if (status == transFail) {
      icon = const Icon(Icons.replay_circle_filled);
    } else if (status == transSuccess) {
      return null;
    } else if (obj.running == processWait || obj.running == processSuspend) {
      icon = const Icon(Icons.play_circle);
    } else if (obj.running == processRunning) {
      icon = const Icon(Icons.pause_circle_filled);
    }
    Widget trail = IconButton(
        onPressed: () {
          tc.processHandler(objList[index], flag, status);
        },
        icon: icon!);

    return trail;
  }

  Widget _buildSelectTrailing() {
    TransObj obj = objList[index];
      setState(() {
        _isSelect = tc.taskMap.containsKey(obj.transID);
      });
      Widget trail = Checkbox(
        value: _isSelect,
        onChanged: (value) {
          setState(() {
            _isSelect = !_isSelect;
          });
          // 加入taskList
          if (_isSelect) {
            tc.taskMap[obj.transID] = obj;
            print('taskMap: ${tc.taskMap}');
          } else {
            tc.taskMap.remove(obj.transID);
            // 任务队列被清空时隐藏任务按钮
            if (tc.taskMap.isEmpty) {
              tc.switchShowAddTask(false);
            }
            print('taskMap: ${tc.taskMap}');
          }
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        activeColor: Colors.blue,
        checkColor: Colors.white,
      );

      return trail;
  }

  Widget _buildListTile() {
    return ListTile(
      leading: objList[index].icon,
      title: _getTitle(),
      subtitle: _getSubTitle(),
      trailing: tc.showAddTask ? _buildSelectTrailing() : _buildNormalTrailing(),
      onTap: () {
        Get.snackbar("提示", "文件${objList[index].fullName}");
      },
      onLongPress: () {
        // 成功和失败的允许选中进行删除
        if (status == transSuccess || status == transFail) {
          TransObj obj = objList[index];
          tc.taskMap[obj.transID] = obj;
          tc.switchShowAddTask(true);
        }
      },
    );
  }

  Widget _buildBox() {
    return Slidable(
      key: ValueKey("$index"),
      //滑动方向
      direction: Axis.horizontal,
      // The end action pane is the one at the right or the bottom side.
      endActionPane:  ActionPane(
        motion: ScrollMotion(),
        children: [
          SlidableAction(
            // An action can be bigger than the others.
            flex: 2,
            onPressed: (BuildContext ctx){
              tc.slideToDelTrans(objList, index, flag, status);
            },
            backgroundColor: Color.fromARGB(255, 227, 64, 24),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: '删除',
          ),
        ],
      ),
      //列表显示的子Item
      child: _buildListTile(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 根据传输状态和类型选择队列
    switch (status) {
      case transProcess:
        objList = (flag == uploadFlag)
            ? tc.uploadList.transList
            : tc.downloadList.transList;
      case transSuccess:
        objList = (flag == uploadFlag)
            ? tc.uploadSuccessList.transList
            : tc.downloadSuccessList.transList;
      case transFail:
        objList = (flag == uploadFlag)
            ? tc.uploadFailList.transList
            : tc.downloadFailList.transList;
    }
    return _buildBox();
  }
}
