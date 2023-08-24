import 'package:flutter/material.dart';
import 'package:cheetah_netdesk/conf/const.dart';
import 'package:get/get.dart';

import '../../components/audio_player.dart';
import '../../controller/file_controller.dart';

class AudioPage extends GetView<FileController> {

  @override
  Widget build(BuildContext context) {
    // 获取controller
    FileController fc = Get.find<FileController>(tag: fcPerTag);
    
    // 获取播放链接
    Map<String, String?> data = Get.parameters;
    String index = data['index']!;
    return Scaffold(
      appBar: AppBar(
        title: Text("音频播放"),
      ),
      body: Column(
        children: [
          SizedBox(height: 40,),
          CustomAudioPlayer(
            audios: fc.audioUrls, index: int.parse(index),
          )
        ],
      ),
    );
  }
}
