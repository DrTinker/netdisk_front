// ignore_for_file: must_be_immutable, no_logic_in_create_state, constant_pattern_never_matches_value_type

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cheetah_netdisk/components/share_pop.dart';
import 'package:cheetah_netdisk/components/toast.dart';
import 'package:cheetah_netdisk/conf/const.dart';
import 'package:cheetah_netdisk/controller/share_controller.dart';
import 'package:cheetah_netdisk/models/share_model.dart';
import 'package:get/get.dart';


class ShareTaskPopContent extends StatefulWidget {
  ShareTaskPopContent({super.key, required this.sc});
  ShareController sc;

  @override
  State<ShareTaskPopContent> createState() => _ShareTaskPopContentState();
}

class _ShareTaskPopContentState extends State<ShareTaskPopContent> {
  _ShareTaskPopContentState();

  List<Widget> _getList() {
    List<Widget> list = [];
    list.add(
      ListTile(title: Text('共选择${widget.sc.taskMap.length}个分享'),)
    );
    // 一定可以取消
    list.add(ListTile(
        leading: shareTaskIconList[0],
        title: Text(shareTaskTypeList[0]),
        onTap: _getTaskHandler(0),
    ));
    // 长度为1
    if (widget.sc.taskMap.length==1) {
      // 只有一个
      widget.sc.taskMap.forEach((key, value) {
        // 有效链接
        if (value.status == shareExpire) {
          list.add(ListTile(
              leading: shareTaskIconList[1],
              title: Text(shareTaskTypeList[1]),
              onTap: _getTaskHandler(1),
          ));
        }
        // 无效链接 
        else {
          list.add(ListTile(
              leading: shareTaskIconList[2],
              title: Text(shareTaskTypeList[2]),
              onTap: _getTaskHandler(2),
          ));
        }
      });
    }
    return list;
  }

  Function()? _getTaskHandler(int index) {
    switch(index) {
      // 取消分享
      case cancelCode:
        return () async{
          await widget.sc.cancelShare();
          widget.sc.clearTaskMap();
          Get.back();
        };
      // 复制链接
      case linkCode:
        return (){
          // taskMap中只有一个
          String target = widget.sc.taskMap.keys.toList()[0];
          // 复制口令到剪切板
          Clipboard.setData(ClipboardData(text: target));
          MsgToast().customeToast('口令已复制');
          widget.sc.clearTaskMap();
          Get.back();
        };
      // 重新分享
      case createCode:
        return () async{
          Get.back();
          // taskMap中只有一个
          ShareObj share = widget.sc.taskMap.values.toList()[0];
          SharePop().showPop(share, widget.sc.token, sc: widget.sc);
          widget.sc.clearTaskMap();
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

class ShareTaskPop {
  showPop(ShareController sc) {
    Get.bottomSheet(
      Container(
        height: 300,
        color: Colors.white,
        child: ShareTaskPopContent(sc: sc),
      ),
      backgroundColor: Colors.white,
    );
  }
}
