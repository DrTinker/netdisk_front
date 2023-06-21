// ignore_for_file: no_logic_in_create_state, must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_learn/components/file_box.dart';
import 'package:flutter_learn/controller/file_controller.dart';

class FileTree extends StatefulWidget {
  FileTree({Key? key, required this.select, required this.ext, required this.fc, })
      : super(key: key);

  FileController fc;
  bool select;
  String ext;
  @override
  State<FileTree> createState() => _FileTreeState(select: select, ext: ext, fc: fc);
}

class _FileTreeState extends State<FileTree> {
  bool select = false;
  String ext;
  FileController fc;
  _FileTreeState({Key? key, required this.select, required this.ext, required this.fc});
  // 监听触底
  ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    // 设置后缀名筛选条件
    fc.setExtFilter(ext);
    // 设置触底监听器
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        fc.getMoreData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 渲染widget
    List<Widget> _getData() {
      List<Widget> list = [];
      for (var i = 0; i < fc.fileObjs.length; i++) {
        // TODO 研究为啥直接传对象不行
        list.add(FileBox(
          //obj: fc.fileObjs[i],
          index: i,
          select: select,
          fc: fc,
        ));
      }
      return list;
    }

    return RefreshIndicator(
        onRefresh: () => fc.getFileObjs(false),
        child: ListView(
          controller: _scrollController,
          children: _getData(),
        ),
    );
  }
}
