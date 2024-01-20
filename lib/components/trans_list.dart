import 'package:flutter/material.dart';
import 'package:cheetah_netdisk/components/toast.dart';
import 'package:cheetah_netdisk/components/trans_box.dart';
import 'package:cheetah_netdisk/conf/const.dart';
import 'package:cheetah_netdisk/controller/trans_controller.dart';
import 'package:cheetah_netdisk/helper/file.dart';

import '../models/trans_model.dart';

// ignore: must_be_immutable
class TransListWidget extends StatefulWidget {
  TransListWidget({super.key, required this.tc, required this.flag});
  TransController tc;
  int flag;

  @override
  State<TransListWidget> createState() =>
      _TransListWidgetState(tc: tc, flag: flag);
}

class _TransListWidgetState extends State<TransListWidget> {
  _TransListWidgetState({required this.tc, required this.flag});
  TransController tc;
  int flag;

  TransList? process;
  TransList? success;
  TransList? fail;

  List<Widget> processView = [];
  List<Widget> successView = [];
  List<Widget> failView = [];

  @override
  void initState() {
    super.initState();
  }

  // 渲染widget
  _getData() {
    if (flag == uploadFlag) {
      process = tc.uploadList;
      success = tc.uploadSuccessList;
      fail = tc.uploadFailList;
    } else {
      process = tc.downloadList;
      success = tc.downloadSuccessList;
      fail = tc.downloadFailList;
    }

    processView = _buildViews(process, transProcess);
    successView = _buildViews(success, transSuccess);
    failView = _buildViews(fail, transFail);
  }

  List<Widget> _buildViews(TransList? objs, int status) {
    List<Widget> list = [];
    for (var i = 0; i < objs!.transList.length; i++) {
      list.add(TransBox(
        index: i,
        tc: tc,
        status: status,
        flag: flag,
      ));
    }
    Widget moreBtn = TextButton(
      child: const Text('更多数据'),
      onPressed: () {
        tc.getMoreData(objs);
      },
    );
    Widget padding = const SizedBox(height: 30);
    list.add(moreBtn);
    list.add(padding);

    return list;
  }

  @override
  Widget build(BuildContext context) {
    _getData();
    return ListView(
      children: [
        SizedBox(height: 20,),
        Row(
          // mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              width: 10,
            ),
            Text('正在进行, 共${process!.transList.length}个'),
            const SizedBox(
              width: 10,
            ),
          ],
        ),
        SizedBox(height: 10,),
        Column(
          children: processView,
        ),
        Row(
          // mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              width: 10,
            ),
            Text('失败任务, 共${fail!.transList.length}个'),
            Spacer(),
            TextButton(onPressed: (){
              tc.clearTransList(flag, transFail);
            }, child: Text('清空')),
            const SizedBox(
              width: 10,
            ),
          ],
        ),
        SizedBox(height: 10,),
        Column(
          children: failView,
        ),
        Row(
          // mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              width: 10,
            ),
            Text('已完成任务, 共${success!.transList.length}个'),
            Spacer(),
            TextButton(onPressed: (){
              tc.clearTransList(flag, transSuccess);
            }, child: Text('清空')),
            const SizedBox(
              width: 10,
            ),
          ],
        ),
        SizedBox(height: 10,),
        Column(
          children: successView,
        ),
      ],
    );
  }
}
