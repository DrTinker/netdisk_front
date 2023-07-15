// ignore_for_file: no_logic_in_create_state, must_be_immutable, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_learn/conf/const.dart';
import 'package:flutter_learn/controller/trans_controller.dart';
import 'package:flutter_learn/models/trans_model.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';

class TransBox extends StatefulWidget {
  TransBox(
      {super.key, required this.tc, required this.index, required this.flag});
  int index;
  int flag;
  TransController tc;
  @override
  State<TransBox> createState() =>
      _TransBoxState(index: index, tc: tc, flag: flag);
}

class _TransBoxState extends State<TransBox> {
  _TransBoxState({required this.tc, required this.index, required this.flag});
  int index;
  int flag;
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
            value: obj.curSize/obj.totalSize,
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
    int dur = DateTime.now().second - time;
    double speed = cur.toDouble() / dur.toDouble();
    if (speed>GB) {
      return '${speed.toStringAsFixed(2)}GB/s';
    }
    if (speed>MB) {
      return '${speed.toStringAsFixed(2)}MB/s';
    }
    return '${speed.toStringAsFixed(2)}KB/s';
  }

  @override
  Widget build(BuildContext context) {
    if (flag == uploadFlag) {
      objList = tc.uploadList.transList;
    } else {
      objList = tc.downloadList.transList;
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
