// ignore_for_file: no_logic_in_create_state, no_leading_underscores_for_local_identifiers, must_be_immutable
import 'package:flutter/material.dart';
import 'package:cheetah_netdisk/controller/share_controller.dart';
import 'package:cheetah_netdisk/components/toast.dart';
import 'package:cheetah_netdisk/helper/parse.dart';
import 'package:cheetah_netdisk/models/share_model.dart';
import 'package:get/get.dart';
import '../conf/const.dart';

class ShareBox extends StatefulWidget {
  ShareBox({Key? key, required this.index, required this.sc, required this.mod})
      : super(key: key);
  int index;
  int mod;
  ShareController sc;
  @override
  State<ShareBox> createState() => _ShareBoxState(index: index, sc: sc);
}

class _ShareBoxState extends State<ShareBox> {
  _ShareBoxState({required this.index, required this.sc});
  int index;
  ShareController sc;
  List<ShareObj> shareList = [];

  bool _isSelect = false;

  @override
  Widget build(BuildContext context) {
    // 根据mod选择对应的list
    switch (widget.mod) {
      case shareAll:
        shareList = sc.shareAllList;
        break;
      case shareExpire:
        shareList = sc.shareExpireList;
        break;
      case shareOut:
        shareList = sc.shareOutList;
        break;
      default:
        break;
    }
    Widget _getTrailing() {
      ShareObj obj = shareList[index];
      setState(() {
        _isSelect = sc.taskMap.containsKey(obj.shareID);
      });
      Widget trail = Checkbox(
        value: _isSelect,
        onChanged: (value) {
          setState(() {
            _isSelect = !_isSelect;
          });
          // 加入taskList
          if (_isSelect) {
            sc.taskMap[obj.shareID] = obj;
            print('taskMap: ${sc.taskMap}');
          } else {
            sc.taskMap.remove(obj.shareID);
            // 任务队列被清空时隐藏任务按钮
            if (sc.taskMap.isEmpty) {
              sc.switchShowAddTask(false);
            }
            print('taskMap: ${sc.taskMap}');
          }
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        activeColor: Colors.blue,
        checkColor: Colors.white,
      );

      return trail;
    }

    Widget _getTitle() {
      ShareObj obj = shareList[index];
      List<String> names = splitName(obj.fullName);
      String name = names[0];
      String ext = names[1];
      return ext == 'folder' ? Text(name) : Text(obj.fullName);
    }

    Widget _getSubTitle() {
      ShareObj obj = shareList[index];
      return obj.status == shareExpire
          ? (obj.expireAt != "" ? Text('有效期至:${obj.expireAt}') : const Text('永久有效'))
          : const Text('链接失效');
    }

    shareHandler() {
      if (sc.showAddTask) {
        MsgToast().customeToast('请先退出选择模式');
        return;
      }
      // 进入前先将当前点击share加入taskMap
      Get.toNamed('/share_detail', parameters: {'index': index.toString(), 'mod': widget.mod.toString()});
    }

    return ListTile(
      leading: shareList[index].icon,
      title: _getTitle(),
      subtitle: _getSubTitle(),
      trailing: sc.showAddTask ? _getTrailing() : null,
      onTap: () {
        shareHandler();
      },
      onLongPress: () {
        ShareObj obj = shareList[index];
        sc.taskMap[obj.shareID] = obj;
        sc.switchShowAddTask(true);
      },
    );
  }
}
