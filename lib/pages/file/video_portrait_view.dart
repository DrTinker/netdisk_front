import 'package:flutter/material.dart';
import 'package:flutter_learn/components/video_player.dart';
import 'package:get/get.dart';

import '../../controller/file_controller.dart';

class VideoPortraitPage extends GetView<FileController> {
  const VideoPortraitPage({super.key});

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
    // 获取播放链接
    Map<String, dynamic> data = Get.parameters;
    String playUrl = data['url'];
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 竖屏播放
          CustomVideoPlayer(playUrl, 1),
        ],
      ),
    );
  }
}
