import 'package:flutter/material.dart';
import 'package:flutter_learn/models/file_model.dart';
import 'package:get/get.dart';

import '../../components/pic_viewer.dart';
import '../../conf/const.dart';
import '../../controller/file_controller.dart';

class PicturePage extends GetView<FileController> {
  const PicturePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 获取controller
    FileController fc = Get.find<FileController>(tag: fcPerTag);
    // 图片链接
    Map<String, String?> data = Get.parameters;
    String index = data['index']!;
    List<String> urls = fc.imageUrls.keys.toList();
    int curIndex = int.parse(index);
    FileObj obj = fc.imageUrls[urls[curIndex]]!;
    return Container(
      child: PhotoViewGalleryScreen(
          images: fc.imageUrls, index: int.parse(index), heroTag: obj.name),
    );
  }
}