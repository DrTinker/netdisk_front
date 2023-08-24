import 'package:flutter/material.dart';
import 'package:cheetah_netdesk/models/file_model.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

// TODO 下载、分享、收藏
// ignore: must_be_immutable
class PhotoViewGalleryScreen extends StatefulWidget {
  // 图片url
  Map<String, FileObj> images = {};
  // 当前展示的图片下标
  int index = 0;
  // 被选中图片名称
  String heroTag;
  PageController? controller;

  PhotoViewGalleryScreen(
      {Key? key,
      required this.images,
      required this.index,
      this.controller,
      required this.heroTag})
      : super(key: key) {
    controller = PageController(initialPage: index);
  }

  @override
  _PhotoViewGalleryScreenState createState() => _PhotoViewGalleryScreenState();
}

class _PhotoViewGalleryScreenState extends State<PhotoViewGalleryScreen> {
  int currentIndex = 0;
  List<String> urls = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentIndex = widget.index;
    urls = widget.images.keys.toList();
  }

  PhotoViewGalleryPageOptions _buildImages(int index) {
    // 请求到则展示图片
    return PhotoViewGalleryPageOptions(
      imageProvider: NetworkImage(urls[index]),
      heroAttributes: widget.heroTag.isNotEmpty
          ? PhotoViewHeroAttributes(tag: widget.heroTag)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            bottom: 0,
            right: 0,
            child: Container(
                child: PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: (BuildContext context, int index) {
                return _buildImages(index);
              },
              itemCount: urls.length,
              // 加载展示
              loadingBuilder: (context, event) => Center(
                child: Container(
                  width: 20.0,
                  height: 20.0,
                  child: CircularProgressIndicator(
                    value: event == null
                        ? 0
                        : event.cumulativeBytesLoaded /
                            event.expectedTotalBytes!,
                  ),
                ),
              ),
              backgroundDecoration: null,
              pageController: widget.controller,
              enableRotation: false,
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
            )),
          ),
          Positioned(
            //图片index显示
            top: MediaQuery.of(context).padding.top + 15,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Text("${currentIndex + 1}/${urls.length}",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
          Positioned(
            //右上角关闭按钮
            right: 10,
            top: MediaQuery.of(context).padding.top,
            child: IconButton(
              icon: Icon(
                Icons.close,
                size: 30,
                color: Colors.white,
              ),
              onPressed: () {
                Get.back();
              },
            ),
          ),
        ],
      ),
    );
  }
}
