import 'package:flutter/material.dart';
import 'package:flutter_learn/components/trans_list.dart';
import 'package:flutter_learn/conf/const.dart';
import 'package:flutter_learn/conf/navi.dart';
import 'package:flutter_learn/controller/trans_controller.dart';
import 'package:get/get.dart';

import '../../components/bottom_bar.dart';
import '../../components/upload_floating.dart';

class TransPage extends GetView<TransController> {
  // TransPage({Key? key, required this.tc}) : super(key: key);
  // TransController tc;
  final List<Tab> myTabs = <Tab>[
    const Tab(text: '上传'),
    const Tab(text: '下载'),
  ];
  @override
  Widget build(BuildContext context) {
    TransController tc = Get.find<TransController>(tag: tcPerTag);
    print('trans page tc: ${tc.hashCode}');

    return DefaultTabController(
      length: myTabs.length,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.blue,
          title: const Text('传输列表'),
          bottom: TabBar(
            tabs: myTabs,
            isScrollable: false,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
          ),
        ),
        floatingActionButton: UploadFloating(tc: tc,),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: GetBuilder<TransController>(
          init: TransController(),
          builder: (controller) {
            List<Widget> contents = [
              TransListWidget(tc: controller, flag: uploadFlag),
              TransListWidget(tc: controller, flag: downloadFlag)
            ];
            return TabBarView(
              children: contents,
            );
          },
        ),
        bottomNavigationBar: BottomBar(index: transPageIndex),
      ),
    );
  }
}
