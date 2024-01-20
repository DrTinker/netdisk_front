import 'package:flutter/material.dart';
import 'package:cheetah_netdisk/components/toast.dart';
import 'package:cheetah_netdisk/conf/code.dart';
import 'package:cheetah_netdisk/conf/url.dart';
import 'package:cheetah_netdisk/controller/user_controller.dart';
import 'package:cheetah_netdisk/helper/net.dart';
import 'package:cheetah_netdisk/models/share_model.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

import '../conf/const.dart';
import '../helper/convert.dart';
import '../helper/storage.dart';
import '../models/user_model.dart';

class ShareController extends GetxController {
  // 用户分享列表
  List<ShareObj> shareAllList = [];
  List<ShareObj> shareExpireList = [];
  List<ShareObj> shareOutList = [];
  Map<String, ShareObj> taskMap = {};
  // 通过分享链接进入后的分享文件详情
  ShareObj? curShare;
  UserObj? curOwner;
  // 登录态
  String token = "";
  // 文件加入任务列表按钮展示
  bool showAddTask = false;
  // 翻页
  int page = 1;

  @override
  void onInit() {
    super.onInit();
    // 尝试读取token和根目录，读不到直接返回，说明没登录
    var store = SyncStorage();
    if (!store.hasKey(userToken) && !store.hasKey(userStartDir)) {
      return;
    }
    if (token == "") {
      token = store.getStorage(userToken);
    }
    // 加载数据
    getAllShareData();
  }

  getAllShareData() async {
    // 请求数据
    await getShareList(false);
    // 遍历填充expire和out
    countOtherList();
    update();
  }

  countOtherList() {
    // 先清空
    shareExpireList = [];
    shareOutList = [];
    for (var element in shareAllList) {
      if (element.status == shareExpire) {
        shareExpireList.add(element);
      } else {
        shareOutList.add(element);
      }
    }
  }

  // 读取传输列表
  getShareList(bool append) async {
    Map<String, String> headers = {
      'Authorization': token,
    };
    Map<String, String> params = {
      'page': page.toString(),
      'mod': shareAll.toString()
    };
    // 删除
    await NetWorkHelper.requestGet(
      shareListUrl,
      (data) {
        var share_list = data['share_list'];
        // 刷新清空
        if (!append) {
          shareAllList.clear();
          // indexMap.clear();
          // 刷新则重置页码
          page = 1;
        }
        for (int i = 0; i < share_list.length; i++) {
          ShareObj shareObj = ShareObj.fromMap(share_list[i]);
          shareAllList.add(shareObj);
          // TODO 处理同一页重复请求错误
          // indexMap[transObj] = i;
        }
      },
      params: params,
      headers: headers,
      transform: JSONConvert.create(),
    );
  }

  // 加载更多
  getMoreData() async {
    if (page <= 0) {
      return;
    }
    page++;
    print('getMoreData, page: $page');
    int preLen = shareAllList.length;
    await getShareList(true);
    int curLen = shareAllList.length;
    // 没有更多数据
    if (curLen == preLen && page > 1) {
      page--;
      print('page: $page');
    } else {
      // 有新数据则更新其他两个队列
      countOtherList();
      update();
    }
    return;
  }

  // 创建分享
  static createShare(ShareObj obj, String token) async {
    Map<String, String> body = {
      'share_uuid': obj.uuid,
      'file_uuid': obj.fileUuid,
      'code': obj.code!,
      'fullname': obj.fullName,
      'expire_at': obj.expireAt!
    };
    await NetWorkHelper.requestPost(
      shareSetUrl,
      (data) {
        int code = data['code'];
        if (code == httpSuccessCode) {
          Get.defaultDialog(
            title: '分享成功',
            content: Column(
              children: [
                Image.asset('assets/icons/link.png', width: 80, height: 80,),
                SizedBox(height: 30,),
                Text('复制口令后在分享界面的搜索栏中输入，即可查看分享')
              ],
            ),
            confirm: ElevatedButton(
              style: ButtonStyle(
                  // 设置圆角
                  shape: MaterialStateProperty.all(const StadiumBorder(
                      side: BorderSide(style: BorderStyle.none)))),
              child: Text('复制口令到剪切板'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: data['share_id']));
                MsgToast().customeToast('口令已复制');
                Get.back();
              },
            ),
          ); // defaultDialog
          return;
        }
        MsgToast().serverErrToast();
      },
      headers: {
        'Authorization': token,
      },
      body: body,
      transform: JSONConvert.create(),
      error: (statusCode, error) {
        print(error);
        MsgToast().serverErrToast();
      },
    );
  }

  // 切换加入任务队列按钮
  switchShowAddTask(bool value) {
    showAddTask = value;
    update();
  }

  clearTaskMap() {
    taskMap.clear();
    showAddTask = false;
    update();
  }

  // 通过链接查看分享详情
  getShareInfo(String uuid) async {
    // 获取分享详情
    await NetWorkHelper.requestGet(
      shareInfoUrl,
      (data) async{
        int code = data['code'];
        if (code == httpSuccessCode) {
          // 获取当前分享详情
          curShare = ShareObj.fromMap(data['info']);
          // 获取分享人
          curOwner = await UserController.getUserProfile(curShare!.userUuid, token);
          update();
          return;
        }
        if (code == shareMissCode) {
          return;
        }
        MsgToast().serverErrToast();
      },
      headers: {
        'Authorization': token,
      },
      params: {'share_uuid': uuid},
      transform: JSONConvert.create(),
      error: (statusCode, error) {
        print(error);
        MsgToast().serverErrToast();
      },
    );
  }

  // 取消分享
  cancelShare({String? uuid}) async {
    List<String> targets = [];
    // taskMap专list
    if (uuid != null) {
      targets.add(uuid);
    } else {
      targets = taskMap.keys.toList();
    }
    // 请求头
    Map<String, String> headers = {
      'Authorization': token,
      'Content-Type': 'application/json',
    };
    // 网络请求
    await NetWorkHelper.requestPost(
      shareCancelUrl,
      (data) {
        MsgToast().customeToast('取消成功');
      },
      headers: headers,
      body: {'Des': "", 'Src': targets},
      transform: JSONConvert.create(),
      error: (code, error) {
        MsgToast().serverErrToast();
      },
    );
    // 刷新
    getAllShareData();
  }

  // 获取文件
  updateShare(ShareObj obj) async{
    Map<String, String> body = {
      'share_uuid': obj.uuid,
      'code': obj.code!,
      'expire_at': obj.expireAt!
    };
    await NetWorkHelper.requestPost(
      shareUpdateUrl,
      (data) {
        int code = data['code'];
        if (code == httpSuccessCode) {
          return;
        }
        MsgToast().serverErrToast();
      },
      headers: {
        'Authorization': token,
      },
      body: body,
      transform: JSONConvert.create(),
      error: (statusCode, error) {
        print(error);
        MsgToast().serverErrToast();
      },
    );
  }
}
