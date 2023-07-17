// ignore_for_file: no_logic_in_create_state, must_be_immutable, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_learn/conf/const.dart';
import 'package:flutter_learn/controller/trans_controller.dart';
import 'package:flutter_learn/models/trans_model.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';

class TransBox extends StatefulWidget {
  TransBox(
      {super.key, required this.tc, required this.index, required this.status, required this.flag});
  int index;
  int flag; // 上传下载标志
  int status; // 传输状态
  TransController tc;
  @override
  State<TransBox> createState() =>
      _TransBoxState(index: index, tc: tc, status: status, flag: flag);
}

class _TransBoxState extends State<TransBox> {
  _TransBoxState({required this.tc, required this.index, required this.status, required this.flag});
  int index;
  int flag; // 上传下载标志
  int status; // 传输状态
  TransController tc;

  List<TransObj> objList = [];
  bool running = false;

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
        SizedBox(height: 10,),
        SizedBox(
          height: 3,
          width: 200,
          child: LinearProgressIndicator(
            value: obj.totalSize==0 ? 0 : obj.curSize/obj.totalSize,
            backgroundColor: Colors.grey,
            valueColor: AlwaysStoppedAnimation(Colors.blue),
          ),
        ),
        SizedBox(height: 10,),
      ],
    );
  }

  Widget _getSubTitle() {
    TransObj obj = objList[index];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('${parseSize(obj.curSize)}/${parseSize(obj.totalSize)}'),
        running ? Text(parseSpeed(obj.curSize, obj.startTime)) : const Text('暂停下载'),
      ],
    );
  }

  String parseSize(int size) {
    double res = size.toDouble();
    if (size>GB) {
      res /= GB;
      return '${res.toStringAsFixed(2)}GB';
    }
    if (size>MB) {
      res /= MB;
      return '${res.toStringAsFixed(2)}MB';
    }
    res /= KB;
    return '${res.toStringAsFixed(2)}KB';
  }

  String parseSpeed(int cur, int time) {
    double dur = (DateTime.now().microsecondsSinceEpoch - time) / 1000000;
    double speed = cur.toDouble() / dur;
    if (speed>GB) {
      speed = speed / GB;
      return '${speed.toStringAsFixed(2)}GB/s';
    }
    if (speed>MB) {
      speed = speed / MB;
      return '${speed.toStringAsFixed(2)}MB/s';
    }
    speed /= KB;
    return '${speed.toStringAsFixed(2)}KB/s';
  }

  @override
  Widget build(BuildContext context) {
    // 根据传输状态和类型选择队列
    switch(status) {
      case transProcess:
        objList = (flag==uploadFlag) ? tc.uploadList.transList : tc.downloadList.transList;
      case transSuccess:
        objList = (flag==uploadFlag) ? tc.uploadSuccessList.transList : tc.downloadSuccessList.transList;
      case transFail:
        objList = (flag==uploadFlag) ? tc.uploadFailList.transList : tc.downloadList.transList;
    }
    return ListTile(
      leading: Image.asset(objList[index].icon, height: 50, width: 50,),
      title: _getTitle(),
      subtitle: _getSubTitle(),
      trailing: running ? const Icon(Icons.pause_circle_filled) : const Icon(Icons.download_for_offline),
      onTap: () {
        setState(() {
          running = !running;
        });
      },
    );
  }
}
