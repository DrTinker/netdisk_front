import 'package:flutter/material.dart';
import 'package:flutter_learn/components/toast.dart';
import 'package:flutter_learn/components/trans_box.dart';
import 'package:flutter_learn/conf/const.dart';
import 'package:flutter_learn/controller/trans_controller.dart';
import 'package:flutter_learn/helper/file.dart';

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
        Row(
          // mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              width: 10,
            ),
            Text('正在进行, 共${process!.transList.length}个'),
            const Spacer(),
            TextButton(
                onPressed: () {
                  MsgToast().customeToast('按钮1');
                  createDir('/data/user/0/com.example.flutter_learn/files/c300e2e6a6d54f5b338');
                },
                child: const Text('全部暂停')),
            const SizedBox(
              width: 10,
            ),
          ],
        ),
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
            const Spacer(),
            TextButton(
                onPressed: () {
                  MsgToast().customeToast('按钮2');
                },
                child: const Text('全部重新开始')),
            const SizedBox(
              width: 10,
            ),
          ],
        ),
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
          ],
        ),
        Column(
          children: successView,
        ),
      ],
    );
  }
}
