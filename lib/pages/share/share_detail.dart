import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cheetah_netdisk/components/card.dart';
import 'package:cheetah_netdisk/models/share_model.dart';
import 'package:get/get.dart';

import '../../components/share_pop.dart';
import '../../components/toast.dart';
import '../../conf/const.dart';
import '../../controller/share_controller.dart';

class ShareDetailPage extends GetView<ShareController> {
  int index = 0;
  int mod = 0;
  List<ShareObj> shareList = [];
  Widget _buildIconBox(ShareController sc) {
    ShareObj share = shareList[index];
    return CardWidget(
        width: 120, height: 120, content: share.icon!, color: Colors.white);
  }

  Widget _buildTextBox(ShareController sc) {
    ShareObj share = shareList[index];
    return ListTile(
      title: Center(
        child: Text(
          share.fullName,
          style: TextStyle(fontSize: 20),
        ),
      ),
      subtitle: Center(
        child: Text(
          '分享于: ${share.createdAt}',
          style: TextStyle(fontSize: 15),
        ),
      ),
    );
  }

  Widget _buildInfoBox(ShareController sc) {
    ShareObj share = shareList[index];
    return GetBuilder<ShareController>(
        init: sc,
        builder: (controller) {
          return share.status == shareExpire
              ? CardWidget(
                  content: Column(mainAxisSize: MainAxisSize.min, children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 200,
                          child: ListTile(
                            title: Text('有效期'),
                            subtitle: share.expireAt == ''
                                ? Text('永久有效')
                                : Text(share.expireAt!),
                          ),
                        ),
                        TextButton(
                            onPressed: () {
                              SharePop().showPop(share, controller.token,
                                  sc: controller);
                            },
                            child: Text('修改'))
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 200,
                          child: ListTile(
                            title: Text('提取码'),
                            subtitle: share.code == null
                                ? Text('无')
                                : Text(share.code!),
                          ),
                        ),
                        TextButton(
                            onPressed: () {
                              SharePop().showPop(share, controller.token,
                                  sc: controller);
                            },
                            child: Text('修改'))
                      ],
                    )
                  ]),
                  color: Colors.white)
              : CardWidget(
                  content: ListTile(
                      title: Text(
                    '链接失效',
                    style: TextStyle(fontSize: 20),
                  )),
                  color: Colors.white);
        });
  }

  Widget _buildBottomButtons(ShareController sc) {
    ShareObj share = shareList[index];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton(
          style: ButtonStyle(
              // 设置圆角
              shape: MaterialStateProperty.all(const StadiumBorder(
                  side: BorderSide(style: BorderStyle.none)))),
          child: Text('取消分享'),
          onPressed: () async {
            // 取消分享
            await sc.cancelShare(uuid: share.uuid);
            // 跳转确认界面
            Get.toNamed('/share_cancel');
          },
        ),
        share.status == shareExpire
            ? ElevatedButton(
                style: ButtonStyle(
                    // 设置圆角
                    shape: MaterialStateProperty.all(const StadiumBorder(
                        side: BorderSide(style: BorderStyle.none)))),
                child: Text('复制链接'),
                onPressed: () async {
                  // 复制口令到剪切板
                  Clipboard.setData(ClipboardData(text: share.uuid));
                  MsgToast().customeToast('口令已复制');
                },
              )
            : ElevatedButton(
                style: ButtonStyle(
                    // 设置圆角
                    shape: MaterialStateProperty.all(const StadiumBorder(
                        side: BorderSide(style: BorderStyle.none)))),
                child: Text('重新分享'),
                onPressed: () async {
                  // 弹出设置弹窗
                  SharePop().showPop(share, sc.token, sc: sc);
                },
              ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // 获取参数
    Map<String, String?> data = Get.parameters;
    index = int.parse(data['index']!);
    mod = int.parse(data['mod']!);
    // 获取sc
    ShareController sc = Get.find<ShareController>();
    switch (mod) {
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

    return Scaffold(
      appBar: AppBar(
        title: Text('分享详情'),
      ),
      body: Form(
          child: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          _buildIconBox(sc),
          _buildTextBox(sc),
          SizedBox(height: 40,),
          _buildInfoBox(sc),
          Spacer(),
          _buildBottomButtons(sc),
          SizedBox(
            height: 20,
          )
        ],
      )),
    );
  }
}
