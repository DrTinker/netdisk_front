import 'package:flutter/material.dart';
import 'package:flutter_learn/components/toast.dart';
import 'package:flutter_learn/components/trans_box.dart';
import 'package:flutter_learn/conf/const.dart';
import 'package:flutter_learn/controller/trans_controller.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';

import '../models/trans_model.dart';

class TransList extends StatefulWidget {
  TransList({super.key, required this.tc, required this.flag});
  TransController tc;
  int flag;

  @override
  State<TransList> createState() => _TransListState(tc: tc, flag: flag);
}

class _TransListState extends State<TransList> {
  _TransListState({required this.tc, required this.flag});
  TransController tc;
  int flag;
  List<TransObj> objList = [];

  // 监听触底
  ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    // 设置触底监听器
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        MsgToast().customeToast('到底了');
      }
    });
  }

  // 渲染widget
  List<Widget> _getRunningData() {
    if (flag == uploadFlag) {
      objList = tc.uploadList;
    } else {
      objList = tc.downloadList;
    }
    List<Widget> list = [];
    for (var i = 0; i < objList.length; i++) {
      list.add(TransBox(
        //obj: fc.fileObjs[i],
        index: i,
        tc: tc,
        flag: flag,
      ));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    var list = _getRunningData();
    return ListView(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('正在进行, 共${objList.length}个'),
            TextButton(onPressed: (){
              MsgToast().customeToast('按钮1');
            }, child: const Text('全部暂停')),
          ],
        ),
        Column(
          children: list,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('失败任务, 共${objList.length}个'),
            TextButton(onPressed: (){
              MsgToast().customeToast('按钮2');
            }, child: const Text('全部重新开始')),
          ],
        ),
        Column(
          children: list,
        ),
      ],
    );
  }
}
