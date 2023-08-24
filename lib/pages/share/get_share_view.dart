import 'package:flutter/material.dart';
import 'package:cheetah_netdesk/components/card.dart';
import 'package:cheetah_netdesk/components/select_pop.dart';
import 'package:cheetah_netdesk/components/toast.dart';
import 'package:cheetah_netdesk/conf/const.dart';
import 'package:cheetah_netdesk/controller/file_controller.dart';
import 'package:cheetah_netdesk/controller/trans_controller.dart';
import 'package:get/get.dart';

import '../../components/file_tree.dart';
import '../../controller/share_controller.dart';

class GetSharePage extends GetView<ShareController> {
  Widget _buildUserInfo(ShareController sc) {
    return ListTile(
      leading: sc.curOwner!.avatar,
      title: Text("${sc.curOwner!.userName}向你分享文件"),
      subtitle: sc.curShare != null && sc.curShare!.expireAt != ""
          ? Text('有效期至:${sc.curShare!.expireAt}')
          : const Text('永久有效'),
    );
  }

  Widget _buildFileTree(FileController fc, ShareController sc) {
    if (sc.curShare == null) {
      return SizedBox();
    }

    // 通过id获取文件信息
    fc.getFileInfo(sc.curShare!.fileUuid);

    return GetBuilder<FileController>(
        global: false,
        init: fc,
        builder: (controller) {
          return Expanded(
              child: FileTree(
            select: true,
            fc: controller,
          ));
        });
  }

  Widget _buildToolBar(
      BuildContext context, FileController fc, TransController tc) {
    final mediaQueryData = MediaQuery.of(context);
    final width = mediaQueryData.size.width * 0.5;
    return Container(
      color: Color.fromARGB(255, 198, 209, 218),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: width,
            child: TextButton.icon(
              icon: Icon(Icons.folder_copy),
              label: Text("保存"),
              onPressed: () {
                FileController outerFC =
                    Get.find<FileController>(tag: fcPerTag);
                // 将内层的taskMap复制过去
                outerFC.taskMap = fc.taskMap;
                // 打开弹窗选择目标文件夹
                SelectPop().showPop(outerFC, copyCode);
                fc.clearTaskMap();
              },
            ),
          ),
          SizedBox(
            width: width,
            child: TextButton.icon(
              icon: Icon(Icons.file_download),
              label: Text("下载"),
              onPressed: () async {
                String downloadPath = fc.getNameListAsPath();
                await tc.addToDownload(fc.curDir, downloadPath, fc.taskMap);
                MsgToast().customeToast('文件已加入下载队列');
                fc.clearTaskMap();
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 获取controllers
    ShareController sc = Get.find<ShareController>();
    FileController fc = Get.find<FileController>(tag: "get_share");
    TransController tc = Get.find<TransController>(tag: tcPerTag);
    // 获取到分享后才渲染界面
    return sc.curOwner != null && sc.curShare != null
        ? WillPopScope(
            child: Scaffold(
              appBar: AppBar(title: Text('获取分享')),
              body: Column(
                children: [
                  CardWidget(
                      content: _buildUserInfo(sc),
                      color: Color.fromARGB(255, 231, 224, 200)),
                  _buildFileTree(fc, sc),
                ],
              ),
              bottomNavigationBar: _buildToolBar(context, fc, tc),
            ),
            onWillPop: () async {
              // 根目录执行退出app逻辑
              if (!fc.isRoot()) {
                // 在root上一层，则返回时只渲染分享的文件
                if (fc.dirList.length == 2) {
                  fc.back(uuid: sc.curShare!.fileUuid);
                } else {
                  fc.back();
                }
                return Future(() => false);
              }
              // fc.dispose();
              return Future(() => true);
            },
          )
        : SizedBox();
  }
}
