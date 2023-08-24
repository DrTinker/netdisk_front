// ignore_for_file: no_logic_in_create_state, must_be_immutable

import 'package:flutter/material.dart';
import 'package:cheetah_netdesk/components/share_box.dart';
import 'package:cheetah_netdesk/controller/share_controller.dart';
import '../conf/const.dart';
import '../models/share_model.dart';
import 'nodata.dart';

class ShareListWidget extends StatefulWidget {
  ShareListWidget({
    Key? key,
    required this.sc,
    required this.mod,
  }) : super(key: key);

  ShareController sc;

  int mod;

  @override
  State<ShareListWidget> createState() => _ShareListWidgetState(sc: sc);
}

class _ShareListWidgetState extends State<ShareListWidget> {
  ShareController sc;
  _ShareListWidgetState({
    Key? key,
    required this.sc,
  });
  // 监听触底
  ScrollController _scrollController = ScrollController();
  List<ShareObj> shareList = [];
  @override
  void initState() {
    super.initState();
    // 设置触底监听器
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        sc.getMoreData();
      }
    });
  }

  // 渲染widget
  List<Widget> _getData() {
    switch (widget.mod) {
      case shareAll:
        shareList = sc.shareAllList;
        break;
      case shareExpire:
        shareList = sc.shareExpireList;
        break;
      case shareOut:
        shareList = sc.shareOutList;
        break;
      default:
        break;
    }
    List<Widget> list = [];
    for (var i = 0; i < shareList.length; i++) {
      // TODO 研究为啥直接传对象不行
      list.add(ShareBox(
        //obj: fc.fileObjs[i],
        index: i,
        sc: sc,
        mod: widget.mod,
      ));
    }
    if (list.isEmpty) {
      return [const NoDataPage()];
    }
    return list;
  }

  Widget _buildRefresher() {
    return RefreshIndicator(
      onRefresh: () {
        return sc.getAllShareData();
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
    return _buildRefresher();
  }
}
