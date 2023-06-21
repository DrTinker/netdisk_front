// ignore_for_file: must_be_immutable
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_learn/components/select_pop.dart';
import 'package:flutter_learn/components/toast.dart';
import 'package:flutter_learn/conf/const.dart';
import 'package:flutter_learn/conf/file.dart';
import 'package:flutter_learn/controller/file_controller.dart';
import 'package:flutter_learn/controller/trans_controller.dart';
import 'package:get/get.dart';

import '../models/trans_model.dart';

class OpenFilePopContent extends StatefulWidget {
  OpenFilePopContent({super.key, required this.tc, required this.fc});
  TransController tc;
  FileController fc;

  @override
  State<OpenFilePopContent> createState() =>
      _OpenFilePopContentState(tc: tc, fc: fc);
}

class _OpenFilePopContentState extends State<OpenFilePopContent> {
  _OpenFilePopContentState({required this.tc, required this.fc});
  TransController tc;
  FileController fc;

  List<PlatformFile> files = [];
  Map content1 = {
    '图片': Image.asset('assets/images/photo2.png'),
    '视频': Image.asset('assets/images/video.png'),
    '音频': Image.asset('assets/images/music.png'),
  };
  Map content2 = {
    '压缩包': Image.asset('assets/images/photo2.png'),
    '文档': Image.asset('assets/images/video.png'),
    '其他': Image.asset('assets/images/music.png'),
  };

  List<Widget> _getButtons(Map content) {
    List<Widget> list = [];
    content.forEach((key, value) {
      list.add(Column(
        children: [
          IconButton(
              iconSize: 80,
              onPressed: () {
                openFilesHandler(key);
              },
              icon: value),
          SizedBox(
            width: 30,
            height: 30,
            child: Text('$key'),
          )
        ],
      ));
    });

    return list;
  }

  openFilesHandler(String key) async {
    List<String>? filter;
    print('文件类型: $key');
    switch (key) {
      case '图片':
        filter = picFilter;
        break;
      case '视频':
        filter = videoFilter;
        break;
      case '音频':
        filter = audioFilter;
        break;
      case '压缩包':
        filter = packFilter;
        break;
      case '文档':
        filter = docFilter;
        break;
      case '其他':
        filter = null;
        break;
      default:
        print('错误文件类型');
        break;
    }
    try {
      FilePickerResult? result;
      if (filter == null) {
        result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          withData: false,
          withReadStream: true,
        );
      } else {
        result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.custom,
          allowedExtensions: filter,
          withData: false,
          withReadStream: true,
        );
      }
      files = result!.files;
    } catch (e) {
      MsgToast().customeToast('文件选择出现错误，可能是选择了不支持类型的文件');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: _getButtons(content1),
        ),
        Row(
          children: _getButtons(content2),
        ),
        ListTile(
          leading: Image.asset(
            'assets/images/folder4.png',
            height: 30,
            width: 30,
          ),
          title: const Text('选择上传位置'),
          onTap: () {
            SelectPop().showPop(fc, uploadCode);
          },
          trailing: ElevatedButton(
              onPressed: () {
                if (fc.uploadPath == "") {
                  MsgToast().customeToast('请先选择上传位置');
                  return;
                }
                try {
                  // 调用上传接口
                  tc.doUpload(fc.uploadPath, files);
                  Get.back();
                } catch (e) {
                  MsgToast().customeToast('上传失败');
                  return;
                }
              },
              child: const Text('上传')),
        ),
      ],
    );
  }
}

class OpenFilePop {
  showPop(TransController tc) {
    Get.bottomSheet(
      Container(
        height: 320,
        color: Colors.white,
        child: OpenFilePopContent(
          fc: FileController(),
          tc: tc,
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
