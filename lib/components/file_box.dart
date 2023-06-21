// ignore_for_file: no_logic_in_create_state, no_leading_underscores_for_local_identifiers, must_be_immutable
import 'package:flutter/material.dart';
import 'package:flutter_learn/controller/file_controller.dart';
import 'package:flutter_learn/models/file_model.dart';
import 'package:flutter_learn/components/toast.dart';

class FileBox extends StatefulWidget {
  FileBox(
      {Key? key, required this.index, required this.select, required this.fc})
      : super(key: key);
  int index;
  final bool select;
  FileController fc;
  @override
  State<FileBox> createState() =>
      _FileBoxState(index: index, select: select, fc: fc);
}

class _FileBoxState extends State<FileBox> {
  _FileBoxState({required this.index, required this.select, required this.fc});
  int index;
  final bool select;
  FileController fc;

  bool _isSelect = false;

  @override
  Widget build(BuildContext context) {
    Widget _getTrailing() {
      File obj = fc.fileObjs[index];
      setState(() {
        _isSelect = fc.taskMap.containsKey(obj.uuid);
      });
      Widget trail = Checkbox(
        value: _isSelect,
        onChanged: (value) {
          setState(() {
            _isSelect = !_isSelect;
          });
          // 加入taskList
          if (_isSelect) {
            fc.taskMap[obj.uuid] = '${obj.name}.${obj.ext}';
            print('taskMap: ${fc.taskMap}');
          } else {
            fc.taskMap.remove(obj.uuid);
            // 任务队列被清空时隐藏任务按钮
            if (fc.taskMap.isEmpty) {
              fc.switchShowAddTask(false);
            }
            print('taskMap: ${fc.taskMap}');
          }
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        activeColor: Colors.blue,
        checkColor: Colors.white,
      );

      return trail;
    }

    String _getTitle() {
      File obj = fc.fileObjs[index];
      if (obj.ext == 'folder') {
        return obj.name;
      }
      return '${obj.name}.${obj.ext}';
    }

    fileHandler() {
      if (fc.showAddTask) {
        MsgToast().customeToast('请先退出选择模式');
        return;
      }
      File obj = fc.fileObjs[index];
      switch (obj.ext) {
        case "folder":
          fc.enter(obj.uuid, obj.name);
          break;
        case "jpg":
          break;
        default:
          MsgToast().customeToast('文件已损坏');
          break;
      }
    }

    return ListTile(
      leading: Image.asset(fc.fileObjs[index].icon),
      title: Text(_getTitle()),
      subtitle: Text(fc.fileObjs[index].updatedAt),
      trailing: fc.showAddTask ? _getTrailing() : null,
      onTap: () {
        fileHandler();
      },
      onLongPress: () {
        // 允许选择，则长按出现选择按钮
        if (select) {
          File obj = fc.fileObjs[index];
          fc.taskMap[obj.uuid] = '${obj.name}.${obj.ext}';
          fc.switchShowAddTask(true);
        }
      },
    );
  }
}
