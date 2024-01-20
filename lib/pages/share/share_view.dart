import 'package:flutter/material.dart';
import 'package:cheetah_netdisk/components/share_list.dart';
import 'package:cheetah_netdisk/components/share_task_pop.dart';
import 'package:cheetah_netdisk/controller/share_controller.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';

import '../../components/bottom_bar.dart';
import '../../components/search_bar.dart';
import '../../components/toast.dart';
import '../../components/upload_floating.dart';
import '../../conf/const.dart';
import '../../conf/navi.dart';
import '../../controller/trans_controller.dart';
import '../../controller/user_controller.dart';

class SharePage extends GetView<ShareController> {
  SharePage({super.key});
  // 检测退出逻辑
  DateTime lastPopTime = DateTime.now();

  final List<Tab> myTabs = <Tab>[
    const Tab(text: '全部'),
    const Tab(text: '有效分享'),
    const Tab(text: '过期分享'),
  ];

  @override
  Widget build(BuildContext context) {
    TransController tc = Get.find<TransController>(tag: tcPerTag);
    ShareController sc = Get.find<ShareController>();
    print('sc1: ${sc.hashCode}');
    return WillPopScope(
      child: DefaultTabController(
        length: myTabs.length,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.blue,
            title: const Text('我的分享'),
            actions: [
              IconButton(
                  onPressed: () {
                    if (sc.taskMap.isEmpty) {
                      MsgToast().customeToast('请先选择要操作的文件');
                      return;
                    }
                    ShareTaskPop().showPop(sc);
                  },
                  icon: Icon(Icons.keyboard_control)),
            ],
            bottom: TabBar(
              tabs: myTabs,
              // 切换时清空taskmap
              onTap: (value) {
                sc.clearTaskMap();
              },
              isScrollable: false,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
            ),
          ),
          floatingActionButton: UploadFloating(
            tc: tc,
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          body: Column(children: [
            SizedBox(height: 20,),
            // 搜索框
            SearchWidget(hintText: '输入口令获取分享', onEditingComplete: (value) async{
              await sc.getShareInfo(value);
              // 跳转code界面
              Get.toNamed('/code');
            },),
            SizedBox(height: 20,),
            // 分享列表
            Flexible(child: GetBuilder<ShareController>(
            init: sc,
            builder: (controller) {
              List<Widget> contents = [
                ShareListWidget(sc: controller, mod: shareAll),
                ShareListWidget(sc: controller, mod: shareExpire),
                ShareListWidget(sc: controller, mod: shareOut),
              ];
              return TabBarView(
                children: contents,
              );
            },
          ),)
          ],),
          bottomNavigationBar: BottomBar(index: sharePageIndex),
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
