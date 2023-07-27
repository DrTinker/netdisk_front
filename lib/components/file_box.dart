// ignore_for_file: no_logic_in_create_state, no_leading_underscores_for_local_identifiers, must_be_immutable
import 'package:flutter/material.dart';
import 'package:flutter_learn/controller/file_controller.dart';
import 'package:flutter_learn/models/file_model.dart';
import 'package:flutter_learn/components/toast.dart';

import '../helper/parse.dart';

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
      FileObj obj = fc.fileObjs[index];
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
            fc.taskMap[obj.uuid] = obj;
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

    Widget _getTitle() {
      FileObj obj = fc.fileObjs[index];
      if (obj.ext == 'folder') {
        return Text(obj.name);
      }
      return Text('${obj.name}.${obj.ext}');
    }

    Widget _getSubTitle() {
      FileObj obj = fc.fileObjs[index];
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(obj.updatedAt),
          Text(parseSize(obj.size)),
        ],
      );
    }

    fileHandler() {
      if (fc.showAddTask) {
        MsgToast().customeToast('请先退出选择模式');
        return;
      }
      FileObj obj = fc.fileObjs[index];
      switch (obj.ext) {
        case "folder":
          fc.enter(obj.uuid, obj.name);
          break;
        // pic
        case "jpg":
          fc.viewPic(obj);
          break;
        case "jpeg":
          fc.viewPic(obj);
          break;
        case "png":
          fc.viewPic(obj);
          break;
        // video
        case "mp4":
          fc.playVedio(obj);
          break;
        case "flv":
          fc.playVedio(obj);
          break;
        case "avi":
          fc.playVedio(obj);
          break;
        // audio 'mp3', 'wma', 'wav', 'ape', 'flac', 'ogg', 'aac'
        case "mp3":
          fc.playAudio(obj);
          break;
        case "wma":
          fc.playAudio(obj);
          break;
        case "m4a":
          fc.playAudio(obj);
          break;
        case "wav":
          fc.playAudio(obj);
        case "ape":
          fc.playAudio(obj);
        case "flac":
          fc.playAudio(obj);
        case "ogg":
          fc.playAudio(obj);
        case "aac":
          fc.playAudio(obj);
          break;
        default:
          MsgToast().customeToast('暂不支持该类型文件预览');
          break;
      }
    }

    return ListTile(
      leading: fc.fileObjs[index].icon,
      title: _getTitle(),
      subtitle: _getSubTitle(),
      trailing: fc.showAddTask ? _getTrailing() : null,
      onTap: () {
        fileHandler();
      },
      onLongPress: () {
        // 允许选择，则长按出现选择按钮
        if (select) {
          FileObj obj = fc.fileObjs[index];
          fc.taskMap[obj.uuid] = obj;
          fc.switchShowAddTask(true);
        }
      },
    );
  }
}
