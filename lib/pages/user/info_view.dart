import 'package:cheetah_netdisk/helper/parse.dart';
import 'package:flutter/material.dart';
import 'package:cheetah_netdisk/components/card.dart';
import 'package:cheetah_netdisk/components/nodata.dart';
import 'package:cheetah_netdisk/components/toast.dart';
import 'package:cheetah_netdisk/components/user_update_pop.dart';
import 'package:cheetah_netdisk/conf/const.dart';
import 'package:cheetah_netdisk/conf/txt.dart';
import 'package:cheetah_netdisk/controller/trans_controller.dart';
import 'package:cheetah_netdisk/controller/user_controller.dart';
import 'package:cheetah_netdisk/helper/device.dart';
import 'package:cheetah_netdisk/helper/storage.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:restart_app/restart_app.dart';

import '../../components/bottom_bar.dart';
import '../../components/upload_floating.dart';
import '../../conf/navi.dart';

class UserInfoPage extends GetView<UserController> {
  UserInfoPage({super.key});
  // 检测退出逻辑
  DateTime lastPopTime = DateTime.now();

  Widget _buildHeader(UserController uc) {
    return ListTile(
      leading: uc.user!.avatar,
      title: Text(
        uc.user!.userName,
        style: const TextStyle(fontSize: 20, color: Colors.black),
      ),
      subtitle: Text(
        uc.user!.email,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.border_color),
        onPressed: () {
          UserUpdatePop().showPop(uc);
        },
      ),
    );
  }

  Widget _buildBtns(int now, int total) {
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.share),
          title: Container(
            transform: Matrix4.translationValues(-20, 0.0, 0.0),
            child: Text('我的分享'),
          ),
          onTap: () {
            Get.toNamed('/share');
          },
        ),
        ListTile(
          leading: Icon(Icons.folder),
          title: Container(
            transform: Matrix4.translationValues(-20, 0.0, 0.0),
            child: Text('我的文件'),
          ),
          onTap: () {
            Get.toNamed('/file');
          },
        ),
        ListTile(
          leading: Icon(Icons.devices),
          title: Container(
            transform: Matrix4.translationValues(-20, 0.0, 0.0),
            child: Text('设备信息'),
          ),
          onTap: () async {
            Get.defaultDialog(
                title: '设备信息',
                content: Column(
                  children: [
                    await deviceInfoHelper(),
                    ListTile(
                      leading: Text('云存储空间: '),
                      title: LinearProgressIndicator(
                        value: total == 0 ? 0 : now / total,
                        backgroundColor: Colors.grey,
                        valueColor: AlwaysStoppedAnimation(Colors.blue),
                        minHeight: 10,
                      ),
                      subtitle: Text('${parseSize(now)}/${parseSize(total)}'),
                    )
                  ],
                ));
          },
        ),
      ],
    );
  }

  Widget _buildVolumeBar(int now, int total) {
    double percent = now.toDouble() / total.toDouble();
    return CircularPercentIndicator(
      radius: 60.0,
      lineWidth: 13.0,
      animation: true,
      percent: percent,
      center: Text(
        "${(percent * 100).toStringAsFixed(1)}%",
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
      ),
      footer: const Text(
        "空间使用情况",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
      ),
      circularStrokeCap: CircularStrokeCap.round,
      progressColor: Colors.purple,
    );
  }

  Widget _buildList() {
    return Column(
      children: [
        ListTile(
          title: Text("关于本站"),
          onTap: () {
            Get.defaultDialog(
              title: '关于本站',
              content: const Text(about),
            );
          },
        ),
        ListTile(
          title: Text("反馈与帮助"),
          onTap: () {
            Get.defaultDialog(
              title: '反馈与帮助',
              content: Column(
                children: [
                  Text('通过微信联系作者'),
                  Image.asset('assets/images/wechat.png')
                ],
              ),
            );
          },
        ),
        ListTile(
          title: Text("退出登录"),
          onTap: () async {
            // 删除存储
            var ps = PersistentStorage();
            await ps.removeStorage(userEmail);
            await ps.removeStorage(userPwd);
            // await ps.removeStorage(userStartDir);
            // 重启app
            Restart.restartApp(webOrigin: '/login');
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    UserController uc = Get.find<UserController>();
    TransController tc = Get.find<TransController>(tag: tcPerTag);
    return WillPopScope(
      child: GetBuilder(
          init: uc,
          builder: (controller) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('个人资料'),
              ),
              body: controller.user != null
                  ? Column(
                      children: [
                        CardWidget(
                            content: _buildHeader(uc), color: Colors.white),
                        Column(
                          children: [
                            // CardWidget(content: _buildBtns(), color: Colors.white),
                            Row(
                              children: [
                                CardWidget(
                                  content: _buildVolumeBar(
                                      controller.user!.nowVolume,
                                      controller.user!.totalVolume),
                                  color: Colors.white,
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  height: 200,
                                ),
                                CardWidget(
                                  content: _buildBtns(
                                      controller.user!.nowVolume,
                                      controller.user!.totalVolume),
                                  color: Colors.white,
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  height: 200,
                                )
                              ],
                            ),
                          ],
                        ),
                        Spacer(),
                        CardWidget(content: _buildList(), color: Colors.white)
                      ],
                    )
                  : const NoDataPage(),
              floatingActionButton: UploadFloating(
                tc: tc,
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              bottomNavigationBar: BottomBar(
                index: userPageIndex,
              ),
            );
          }),
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
