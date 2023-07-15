import 'package:flutter/material.dart';
import 'package:flutter_learn/components/toast.dart';
import 'package:flutter_learn/components/trans_box.dart';
import 'package:flutter_learn/conf/const.dart';
import 'package:flutter_learn/controller/trans_controller.dart';

import '../models/trans_model.dart';

// ignore: must_be_immutable
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

  @override
  void initState() {
    super.initState();
  }

  // 渲染widget
  List<Widget> _getRunningData() {
    if (flag == uploadFlag) {
      objList = tc.uploadList.transList;
    } else {
      objList = tc.downloadList.transList;
    }
    List<Widget> list = [];
    for (var i = 0; i < objList.length; i++) {
      list.add(TransBox(
        index: i,
        tc: tc,
        flag: flag,
      ));
    }
    Widget moreBtn = TextButton(
      child: const Text('更多数据'),
      onPressed: () {
        MsgToast().customeToast("更多数据正在赶来");
      },
    );
    Widget padding = const SizedBox(height: 30);
    list.add(moreBtn);
    list.add(padding);
    return list;
  }

  @override
  Widget build(BuildContext context) {
    var list = _getRunningData();
    return ListView(
      children: [
        Row(
          // mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(width: 10,),
            Text('正在进行, 共${objList.length}个'),
            const Spacer(),
            TextButton(onPressed: (){
              MsgToast().customeToast('按钮1');
            }, child: const Text('全部暂停')),
            const SizedBox(width: 10,),
          ],
        ),
        Column(
          children: list,
        ),
        
        Row(
          // mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(width: 10,),
            Text('失败任务, 共${objList.length}个'),
            const Spacer(),
            TextButton(onPressed: (){
              MsgToast().customeToast('按钮2');
            }, child: const Text('全部重新开始')),
            const SizedBox(width: 10,),
          ],
        ),
        Column(
          children: list,
        ),

        Row(
          // mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(width: 10,),
            Text('已完成任务, 共${objList.length}个'),
          ],
        ),
        Column(
          children: list,
        ),
      ],
    );
  }
}
