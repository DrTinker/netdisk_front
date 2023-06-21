import 'package:flutter_learn/conf/const.dart';
import 'package:flutter_learn/helper/storage.dart';
import 'package:get/get.dart';
import '../components/toast.dart';
import '../models/file_model.dart';
import '../../conf/url.dart';
import '../../helper/convert.dart';
import '../../helper/net.dart';

class FileController extends GetxController {
  // 文件列表
  List<File> fileObjs = [];
  int page = 1;
  String extFilter = "";
  // 目录
  List<String> dirList = [];
  List<String> nameList = [];
  String curDir = "";
  String curName = "";
  // 文件加入任务列表按钮展示
  bool showAddTask = false;
  // 任务列表
  Map<String, String> taskMap = {};
  // 用户登录
  String token = "";
  // 上传下载相关
  String uploadPath = "";

  @override
  void onInit() {
    // 尝试读取token和根目录，读不到直接返回，说明没登录
    var store = SyncStorage();
    if (!store.hasKey(userToken) && !store.hasKey(userStartDir)) {
      return;
    }
    // 否则已经登录，查看token和dir是否为空，为空说明初次创建fc
    if (token == "" && curDir == "" && dirList.isEmpty) {
      token = store.getStorage(userToken);
      curDir = store.getStorage(userStartDir);
      uploadPath = curDir; // 初始化上传路径为根目录
      dirList.add(curDir);
      curName = "我的空间";
      nameList.add(curName);
    }
    // token和dir不为空的时候加载数据
    if (token == "" || curDir == "") {
      return;
    }
    // 加载数据
    getFileObjs(false);
    super.onInit();
  }

  @override
  void onReady() {
    // onReady在组件创建之后调用，不能在这里加载数据
  }

  @override
  void onClose() {}

  // 判断是否根目录
  bool isRoot() {
    var store = SyncStorage();
    String start = "";
    if (store.hasKey(userStartDir)) {
      start = store.getStorage(userStartDir);
    }
    return start == curDir;
  }

  // 切换目录
  // 进入文件夹
  enter(String dir, String name) {
    if (dir == "") {
      return;
    }
    dirList.add(dir);
    curDir = dir;
    nameList.add(name);
    curName = name;
    // 清零page
    page = 1;
    print("nameList: $nameList, cur: $curDir, name: $curName, page: $page");
    getFileObjs(false);
  }

  // 退出文件夹
  back() {
    // 至少有一层根目录
    if (dirList.length == 1 || nameList.length == 1) {
      return;
    }
    dirList.removeAt(dirList.length - 1);
    curDir = dirList[dirList.length - 1];
    nameList.removeAt(nameList.length - 1);
    curName = nameList[nameList.length - 1];
    // 清零page
    page = 1;
    print("nameList: $nameList, cur: $curDir, name: $curName, page: $page");
    getFileObjs(false);
  }

  // 设置后缀名筛选条件
  setExtFilter(String ext) {
    extFilter = ext;
  }

  // 切换加入任务队列按钮
  switchShowAddTask(bool value) {
    showAddTask = value;
    update();
  }

  // 清空任务队列
  clearTaskMap() {
    taskMap.clear();
    showAddTask = false;
    // 手动刷新一下
    getFileObjs(false);
  }

  // 网络请求
  // 获取路径下文件列表
  getFileObjs(bool append) async {
    // token或curDir为空，说明还未初始化
    if (token == "" || curDir == "") {
      return;
    }
    if (!append) {
      // 每次刷新都不展示任务按钮
      showAddTask = false;
      // 若为刷新则重置页码
      page = 1;
    }
    // 请求文件接口
    String url = fileInfoUrl;
    Map<String, String> headers = {
      'Authorization': token,
    };
    Map<String, String> params1 = {
      'parent_uuid': curDir,
      'page': page.toString(),
      'ext': extFilter,
    };
    await NetWorkHelper.requestGet(
      url,
      (data) {
        var fileList = data['file_list'];
        // 刷新清空
        if (!append) {
          fileObjs.clear();
        }
        // file是map
        for (var file in fileList) {
          File fileObj = File.fromMap(file);
          fileObjs.add(fileObj);
        }
      },
      params: params1,
      headers: headers,
      transform: JSONConvert.create(),
    );
    update();
  }

  // 触底加载
  getMoreData() async {
    if (page <= 0) {
      return;
    }
    page++;
    print('getMoreData, page: $page');
    int preLen = fileObjs.length;
    await getFileObjs(true);
    int curLen = fileObjs.length;
    // 没有更多数据
    if (curLen == preLen && page > 1) {
      page--;
      print('page: $page');
    }
    return;
  }

  // 创建文件夹
  mkDir(String newFolderName) async {
    if (newFolderName == "" || token == "" || curDir == "") {
      return;
    }
    // 请求文件接口
    String url = mkDirUrl;
    Map<String, String> headers = {
      'Authorization': token,
    };
    Map<String, String> body = {
      'name': newFolderName,
      'parent_uuid': curDir,
    };
    await NetWorkHelper.requestPost(
      url,
      (data) {
        print('创建成功: ${data['file_id']}');
        Get.snackbar("提示", "文件创建成功");
      },
      body: body,
      headers: headers,
      transform: JSONConvert.create(),
      error: (statusCode, error) {
        MsgToast().serverErrToast();
      },
    );
    // 刷新界面
    await getFileObjs(false);
  }

  // 增删改, 由于实现原因这里面没有做刷新，调用时记得调用clearTaskMap()在那个里面刷新主界面
  doTask(int index) async {
    print(
        "do task nameList: $nameList, cur: $curDir, name: $curName, page: $page, task: $index");
    // 参数
    String desID = curDir;
    if (taskMap.containsKey(desID)) {
      MsgToast().customeToast('文件不能移动或复制到自己的目录下');
      return;
    }
    List<String> srcIDList = [];
    taskMap.forEach((key, value) {
      srcIDList.add(key);
    });
    // 请求头
    Map<String, String> headers = {
      'Authorization': token,
      'Content-Type': 'application/json',
    };
    switch (index) {
      case copyCode:
        await NetWorkHelper.requestPost(
          copyUrl,
          (data) {
            resultHandler(data);
          },
          headers: headers,
          body: {'Des': desID, 'Src': srcIDList},
          transform: JSONConvert.create(),
          error: (code, error) {
            MsgToast().serverErrToast();
          },
        );
        break;
      case moveCode:
        await NetWorkHelper.requestPost(
          moveUrl,
          (data) {
            resultHandler(data);
          },
          headers: headers,
          body: {'Des': desID, 'Src': srcIDList},
          transform: JSONConvert.create(),
          error: (code, error) {
            MsgToast().serverErrToast();
          },
        );
        break;
      case deleteCode:
        await NetWorkHelper.requestPost(
          deleteUrl,
          (data) {
            resultHandler(data);
          },
          headers: headers,
          body: {'Des': '', 'Src': srcIDList},
          transform: JSONConvert.create(),
          error: (code, error) {
            MsgToast().serverErrToast();
          },
        );
        break;
      case downloadCode:
        break;
      case shareCode:
        break;
      default:
        MsgToast().customeToast('操作类型错误');
        return () {};
    } // switch
  }

  // 上传下载
  setUploadPath(String path) {
    uploadPath = path;
  }

  // 重命名
  rename(String id, String fullname) async {
    await NetWorkHelper.requestPost(
      renameUrl,
      (data) {
        MsgToast().customeToast('文件操作成功');
      },
      headers: {'Authorization': token},
      body: {'file_uuid': id, 'name': fullname},
      transform: JSONConvert.create(),
      error: (code, error) {
        MsgToast().serverErrToast();
      },
    );
    await clearTaskMap();
  }

  // 任务类请求结果处理方法
  resultHandler(data) {
    var success = data['success'];
    var fail = data['fail'];
    int total = data['total'];
    if (success.length == total) {
      MsgToast().customeToast('文件操作成功');
    } else {
      MsgToast()
          .customeToast('共操作$total, 成功${success.length}, 失败${fail.length}');
    }
  }
}
