// ignore_for_file: must_be_immutable, no_logic_in_create_state, constant_pattern_never_matches_value_type

import 'package:flutter/material.dart';
import 'package:cheetah_netdesk/components/toast.dart';
import 'package:cheetah_netdesk/conf/const.dart';
import 'package:cheetah_netdesk/controller/trans_controller.dart';
import 'package:get/get.dart';


class TransTaskPopContent extends StatefulWidget {
  TransTaskPopContent({super.key, required this.tc, required this.mod});
  TransController tc;
  int mod;

  @override
  State<TransTaskPopContent> createState() => _TransTaskPopContentState();
}

class _TransTaskPopContentState extends State<TransTaskPopContent> {
  _TransTaskPopContentState();

  List<Widget> _getList() {
    List<Widget> list = [];
    list.add(
      ListTile(title: Text('共选择${widget.tc.taskMap.length}个传输记录'),)
    );
    // 删除
    list.add(ListTile(
        leading: transTaskIconList[0],
        title: Text(transTaskTypeList[0]),
        onTap: _getTaskHandler(0),
    ));
    return list;
  }

  Function()? _getTaskHandler(int index) {
    switch(index) {
      // 取消分享
      case tdeleteCode:
        return () async{
          await widget.tc.delTransBatch(widget.mod);
          widget.tc.clearTaskMap();
          Get.back();
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

class TransTaskPop {
  showPop(TransController tc, int mod) {
    Get.bottomSheet(
      Container(
        height: 300,
        color: Colors.white,
        child: TransTaskPopContent(tc: tc, mod: mod,),
      ),
      backgroundColor: Colors.white,
    );
  }
}
