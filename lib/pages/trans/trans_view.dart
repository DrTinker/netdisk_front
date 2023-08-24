import 'package:flutter/material.dart';
import 'package:cheetah_netdesk/components/trans_list.dart';
import 'package:cheetah_netdesk/components/trans_task_pop.dart';
import 'package:cheetah_netdesk/conf/const.dart';
import 'package:cheetah_netdesk/conf/navi.dart';
import 'package:cheetah_netdesk/controller/trans_controller.dart';
import 'package:get/get.dart';

import '../../components/bottom_bar.dart';
import '../../components/toast.dart';
import '../../components/upload_floating.dart';
import '../../controller/user_controller.dart';

class TransPage extends GetView<TransController> {
  // TransPage({Key? key, required this.tc}) : super(key: key);
  // TransController tc;
  final List<Tab> myTabs = <Tab>[
    const Tab(text: '上传'),
    const Tab(text: '下载'),
  ];
  // 检测退出逻辑
  DateTime lastPopTime = DateTime.now();
  int cur = 0;

  @override
  Widget build(BuildContext context) {
    TransController tc = Get.find<TransController>(tag: tcPerTag);
    print('trans page tc: ${tc.hashCode}');

    return WillPopScope(
      child: DefaultTabController(
        length: myTabs.length,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.blue,
            title: const Text('传输列表'),
            actions: [
              IconButton(
                  onPressed: () {
                    if (tc.taskMap.isEmpty) {
                      MsgToast().customeToast('请先选择要操作的文件');
                      return;
                    }
                    TransTaskPop().showPop(tc, cur);
                  },
                  icon: Icon(Icons.keyboard_control)),
            ],
            bottom: TabBar(
              tabs: myTabs,
              isScrollable: false,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              onTap: (value) {
                // 切换时清空taskmap
                tc.clearTaskMap();
                // 记录当且页面
                cur = value;
              },
            ),
          ),
          floatingActionButton: UploadFloating(
            tc: tc,
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
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
      ),
      onWillPop: () async {
        // 根目录执行退出app逻辑
        if (DateTime.now().difference(lastPopTime) > Duration(seconds: 1)) {
          lastPopTime = DateTime.now();
          MsgToast().customeToast("再按一次退出");
          return Future.value(false);
        } else {
          lastPopTime = DateTime.now();
          // 退出app
          return Future.value(true);
        }
      },
    );
  }
}
