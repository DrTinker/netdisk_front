// ignore_for_file: no_logic_in_create_state, must_be_immutable

import 'package:flutter/material.dart';
import 'package:cheetah_netdisk/components/file_box.dart';
import 'package:cheetah_netdisk/components/nodata.dart';
import 'package:cheetah_netdisk/controller/file_controller.dart';
import 'package:cheetah_netdisk/models/file_model.dart';

class FileTree extends StatefulWidget {
  FileTree(
      {Key? key,
      required this.select,
      this.exts,
      required this.fc,
      this.isStatic})
      : super(key: key);

  FileController fc;
  bool select;
  List<String>? exts;
  bool? isStatic;
  @override
  State<FileTree> createState() =>
      _FileTreeState(select: select, fc: fc);
}

class _FileTreeState extends State<FileTree> {
  bool select = false;
  FileController fc;
  _FileTreeState(
      {Key? key,
      required this.select,
      required this.fc,});
  // 默认非静态
  bool? isStatic;
  // 监听触底
  ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    // 设置触底监听器
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        fc.getMoreData();
      }
    });
  }

  // 渲染widget
  List<Widget> _getData() {
    List<Widget> list = [];
    // 顶部空隙
    list.add(SizedBox(height: 10,));
    for (var i = 0; i < fc.fileObjs.length; i++) {
      FileObj obj = fc.fileObjs[i];
      if (widget.exts!=null && widget.exts!.isNotEmpty && !widget.exts!.contains(obj.ext)) {
        continue;
      }
      // TODO 研究为啥直接传对象不行
      list.add(FileBox(
        //obj: fc.fileObjs[i],
        index: i,
        select: select,
        fc: fc,
      ));
    }
    if (fc.fileObjs.isEmpty) {
      list.add(const NoDataPage());
      return list;
    }
    // 底部空隙
    list.add(SizedBox(height: 20,));
    return list;
  }

  Widget _buildRefresher() {
    return RefreshIndicator(
      onRefresh: () {
        return fc.getFileObjs(false);
      },
      child: ListView(
        // 非静态才监听触底事件
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        children: _getData(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isStatic == null || isStatic == false ? _buildRefresher() : ListView(children: _getData(),);
  }
}
