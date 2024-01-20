// ignore_for_file: must_be_immutable

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cheetah_netdisk/components/select_pop.dart';
import 'package:cheetah_netdisk/components/toast.dart';
import 'package:cheetah_netdisk/conf/const.dart';
import 'package:cheetah_netdisk/conf/file.dart';
import 'package:cheetah_netdisk/controller/file_controller.dart';
import 'package:cheetah_netdisk/controller/trans_controller.dart';
import 'package:cheetah_netdisk/controller/user_controller.dart';
import 'package:get/get.dart';


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
    '图片': Image.asset('assets/icons/pic.png', width: 30, height: 30,),
    '视频': Image.asset('assets/icons/video.png', width: 30, height: 30,),
    '音频': Image.asset('assets/icons/music.png', width: 30, height: 30,),
  };
  Map content2 = {
    '压缩包': Image.asset('assets/icons/zip.png', width: 30, height: 30),
    '文档': Image.asset('assets/icons/txt.png', width: 30, height: 30),
    '其他': Image.asset('assets/icons/nodata.png', width: 30, height: 30),
  };

  List<Widget> _getButtons(Map content) {
    List<Widget> list = [];
    content.forEach((key, value) {
      list.add(Column(
        children: [
          IconButton(
              iconSize: 60,
              onPressed: () {
                openFilesHandler(key);
              },
              icon: value),
          SizedBox(
            width: 60,
            height: 20,
            child: Center(child: Text('$key'),),
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
      if (result == null) {
        print('用户未选择文件');
        return;
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
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _getButtons(content1),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _getButtons(content2),
        ),
        Spacer(),
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
                if (fc.uploadDir == "") {
                  MsgToast().customeToast('请先选择上传位置');
                  return;
                }
                try {
                  Get.back();
                  // 调用上传接口
                  tc.addToUpload(fc.uploadDir, fc.uploadPath, files);
                } catch (e) {
                  MsgToast().customeToast('上传失败');
                  return;
                }
              },
              child: const Text('上传')),
        ),
        SizedBox(height: 20,)
      ],
    );
  }
}

class OpenFilePop {
  showPop(TransController tc) {
    Get.bottomSheet(
      Container(
        height: 300,
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
