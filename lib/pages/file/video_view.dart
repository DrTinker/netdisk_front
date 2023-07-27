import 'package:flutter/material.dart';
import 'package:flutter_learn/components/file_tree.dart';
import 'package:flutter_learn/components/video_player.dart';
import 'package:flutter_learn/conf/const.dart';
import 'package:flutter_learn/conf/file.dart';
import 'package:get/get.dart';

import '../../controller/file_controller.dart';

class VideoPage extends GetView<FileController> {
  const VideoPage({super.key});

  Widget _buildTitle(String str) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(width: 15,),
        Text(
          str,
          style: TextStyle(fontSize: 24),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // 获取controller
    FileController fc = Get.find<FileController>(tag: fcPerTag);
    // 获取播放链接
    Map<String, dynamic> data = Get.parameters;
    String playUrl = data['url'];
    String fullName = data['fullName'];
    String size = data['size'];
    return Scaffold(
      appBar: AppBar(
        title: Text("视频播放"),
      ),
      body: Column(
        children: [
          // 横屏播放
          CustomVideoPlayer(playUrl, 0),
          const SizedBox(
            height: 10,
          ),
          _buildTitle('简介'),
          ListTile(
            title: Text(fullName),
            subtitle: Text(size),
          ),
          const SizedBox(
            height: 10,
          ),
          _buildTitle("精选"),
          Expanded(child: FileTree(select: false, exts: videoFilter, fc: fc, isStatic: true,))
        ],
      ),
    );
  }
}
