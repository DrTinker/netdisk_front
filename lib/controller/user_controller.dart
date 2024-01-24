import 'package:cheetah_netdisk/models/user_model.dart';
import 'package:get/get.dart';

import '../components/toast.dart';
import '../conf/code.dart';
import '../conf/const.dart';
import '../conf/url.dart';
import '../helper/convert.dart';
import '../helper/net.dart';
import '../helper/storage.dart';

class UserController extends GetxController {
  UserObj? user;
  String token = "";

  @override
  void onInit() {
    // TODO: implement onInit
    var store = SyncStorage();
    if (!store.hasKey(userToken) && !store.hasKey(userStartDir)) {
      return;
    }
    token = store.getStorage(userToken);
    getUserInfo();
    // await ps.setStorage(userInfo, user);
    // if (user != null) {
    //   // 获取用户根目录
    //   var store = SyncStorage();
    //   store.setStorage(userStartDir, user!.startID);
    // }
    super.onInit();
  }

  static Future<bool> doLogin(String email, password, {bool? navi}) async {
    bool res = true;
    // 请求登录接口
    var url = loginUrl;
    Map<String, String> params = {'userEmail': email, 'userPwd': password};
    await NetWorkHelper.requestGet(
        url,
        // success
        (data) async {
          var ps = PersistentStorage();
          // var store = SyncStorage();
          if (data['code'] == loginErrCode) {
            MsgToast().customeToast("邮箱或密码错误");
            res = false;
            return;
          }
          // 磁盘写入email和pwd，用于记住用户
          await ps.setStorage(userToken, data['token']);
          // String dir = data['data']['Start_Uuid'];
          // await ps.setStorage(userStartDir, dir);
          await ps.setStorage(userEmail, email);
          await ps.setStorage(userPwd, password);
          var aa = await ps.getKeys();
          // 写入全局map，保存登录态
          var store = SyncStorage();
          String dir = data['data']['startID'];
          store.setStorage(userStartDir, dir);
          store.setStorage(userToken, data['token']);
          // 查看是否跳转页面
          if (navi == null || navi) {
            // 跳转主页
            Get.offAllNamed('/file');
          }
        },
        params: params,
        transform: JSONConvert.create(),
        error: (code, error) {
          res = false;
          MsgToast().serverErrToast();
        });

    return res;
  }

  static doSignup(String userName, email, password, phone, code) async {
    // 请求登录接口
    var url = registerUrl;
    Map<String, String> body = {
      'userName': userName,
      'userPwd': password,
      'userEmail': email,
      'userPhone': phone
    };
    NetWorkHelper.requestPost(
        url,
        // success
        (data) {
          if (data['code'] == httpSuccessCode) {
            // 成功
            Get.offAllNamed('/login',
                parameters: {'email': email, 'password': password});
            return;
          }
          // 失败
          if (data['code'] == userExistCode) {
            MsgToast().customeToast('该邮箱已经被注册');
            return;
          }
          if (data['code'] == verifyErrorCode) {
            MsgToast().customeToast('验证码错误');
            return;
          }
        },
        headers: {'Content-Type': "application/json"},
        params: {'code': code},
        body: body,
        transform: JSONConvert.create(),
        error: (code, error) {
          MsgToast().serverErrToast();
        });
  }

  static sendCode(String email) async {
    // 邮件发送接口
    var url = sendCodeUrl;
    Map<String, String> params = {'userEmail': email};
    NetWorkHelper.requestGet(
        url,
        // success
        (data) {
          if (data['code'] == httpSuccessCode) {
            MsgToast().customeToast("邮件已发送");
            return;
          }
        },
        params: params,
        transform: JSONConvert.create(),
        error: (code, error) {
          MsgToast().serverErrToast();
        });
  }

  static sendForget(String email, phone) async {
    // 邮件发送接口
    var url = sendForgetUrl;
    Map<String, String> params = {'userEmail': email, 'userPhone': phone};
    NetWorkHelper.requestGet(
        url,
        // success
        (data) {
          if (data['code'] == httpSuccessCode) {
            MsgToast().customeToast("密码已发送至邮箱");
            return;
          }
        },
        params: params,
        transform: JSONConvert.create(),
        error: (code, error) {
          MsgToast().serverErrToast();
        });
  }

  doRename(String name) {
    // 改名接口
    var url = renameUrl;
    Map<String, String> body = {'userName': name};
    NetWorkHelper.requestPost(
        url,
        // success
        (data) {
          if (data['code'] == httpSuccessCode) {
            MsgToast().customeToast("用户名修改成功");
            user!.userName = name;
            return;
          }
          MsgToast().serverErrToast();
        },
        headers: {'Authorization': token},
        body: body,
        transform: JSONConvert.create(),
        error: (code, error) {
          MsgToast().serverErrToast();
        });
  }

  getUserInfo() async {
    await NetWorkHelper.requestGet(
        userInfoUrl,
        // success
        (data) {
          if (data['code'] == httpSuccessCode) {
            user = UserObj.fromInfoMap(data['info']);
            update();
            return;
          }
        },
        headers: {'Authorization': token},
        transform: JSONConvert.create(),
        error: (code, error) {
          MsgToast().serverErrToast();
        });
  }

  static Future<UserObj?> getUserProfile(String userID, token) async {
    UserObj? res;
    await NetWorkHelper.requestGet(
        userProfileUrl,
        // success
        (data) {
          if (data['code'] == httpSuccessCode) {
            res = UserObj.fromInfoMap(data['info']);
            return;
          }
        },
        headers: {'Authorization': token},
        params: {'userID': userID},
        transform: JSONConvert.create(),
        error: (code, error) {
          MsgToast().serverErrToast();
        });
    return res;
  }
}
