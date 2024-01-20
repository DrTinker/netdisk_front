
import 'package:cheetah_netdisk/conf/const.dart';
import 'package:cheetah_netdisk/conf/file.dart';
import 'package:cheetah_netdisk/helper/file.dart';
import 'package:cheetah_netdisk/helper/parse.dart';
import 'package:cheetah_netdisk/helper/storage.dart';
import 'package:get/get.dart';
import '../components/toast.dart';
import '../conf/code.dart';
import '../models/file_model.dart';
import '../../conf/url.dart';
import '../../helper/convert.dart';
import '../../helper/net.dart';

class FileController extends GetxController {
  // 文件列表
  List<FileObj> fileObjs = [];
  int page = 1;
  // 目录
  List<String> dirList = [];
  List<String> nameList = [];
  String curDir = "";
  String curName = "";
  // 文件加入任务列表按钮展示
  bool showAddTask = false;
  // 任务列表
  Map<String, FileObj> taskMap = {};
  // 用户登录
  String token = "";
  // 上传下载相关
  String uploadDir = "";
  String uploadPath = "";
  // 图片
  Map<String, FileObj> imageUrls = {};
  // 音频
  Map<String, FileObj> audioUrls = {};
  // 禁止根目录刷新，用于获取分享文件列表
  bool banRootRefresh = false;

  @override
  void onInit() async{
    // 尝试读取token和根目录，读不到直接返回，说明没登录
    var store = SyncStorage();
    if (!store.hasKey(userToken) && !store.hasKey(userStartDir)) {
      return;
    }
    // 否则已经登录，查看token和dir是否为空，为空说明初次创建fc
    if (token == "" && curDir == "" && dirList.isEmpty) {
      token = store.getStorage(userToken);
      curDir = store.getStorage(userStartDir);
      uploadDir = curDir; // 初始化上传路径为根目录
      uploadPath = "我的空间";
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
  // 传入uuid时，只会获取uuid对应一个文件的信息
  back({String? uuid}) {
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
    // 处理分享的情况
    if (uuid != null) {
      getFileInfo(uuid);
      return;
    }
    getFileObjs(false);
  }

  // 播放视频
  playVedio(FileObj obj) async {
    // 查看本地
    // 拼接地址
    String dir = getNameListAsPath();
    String filePath = await getDownloadDir('${obj.name}.${obj.ext}', dir);
    bool flag = fileExist(filePath);
    // 传递参数
    Map<String, String> param = {};
    param['fullName'] = obj.name;
    param['size'] = parseSize(obj.size);
    if (flag) {
      param['url'] = filePath;
      Get.toNamed('/video', parameters: param);
    } else {
      // 不在本地，请求sign
      String sign = await getPreSign(obj);
      param['url'] = sign;
      Get.toNamed('/video', parameters: param);
    }
  }

  // 播放音频
  playAudio(FileObj obj) async {
    // 查看本地
    // 清空map
    audioUrls.clear();
    // 遍历当前目录，找到所有图片后缀的文件
    int index = -1;
    int cnt = 0;
    for (int i = 0; i < fileObjs.length; i++) {
      FileObj f = fileObjs[i];
      // 是图片
      if (audioFilter.contains(f.ext)) {
        // 拼接地址
        String dir = getNameListAsPath();
        String filePath = await getDownloadDir('${f.name}.${f.ext}', dir);
        bool flag = fileExist(filePath);
        if (flag) {
          audioUrls[filePath] = f;
        } else {
          // 获取文件地址
          String url = await getPreSign(f);
          // 加入结果集
          audioUrls[url] = f;
        }
        // 如果是目标，则更新index
        if (f == obj) {
          index = cnt;
        }
        cnt++;
      }
    }
    // 如果结果为空则返回
    if (audioUrls.isEmpty || index==-1) {
      MsgToast().customeToast('获取音频失败');
      return;
    }
    // 成功则跳转图片页面
    Get.toNamed('/audio', parameters: {'index': index.toString()});
  }
  // 查看图片
  viewPic(FileObj obj) async {
    // 清空map
    imageUrls.clear();
    // 遍历当前目录，找到所有图片后缀的文件
    int index = -1;
    int cnt = 0;
    for (int i = 0; i < fileObjs.length; i++) {
      FileObj f = fileObjs[i];
      // 是图片
      if (picFilter.contains(f.ext)) {
        // 获取文件地址
        String url = await getPreSign(f);
        // 加入结果集
        imageUrls[url] = f;
        // 如果是目标，则更新index
        if (f == obj) {
          index = cnt;
        }
        cnt++;
      }
    }
    // 如果结果为空则返回
    if (index == -1 || imageUrls.isEmpty) {
      MsgToast().customeToast('获取图片失败');
      return;
    }
    // 成功则跳转图片页面
    Get.toNamed('/pic', parameters: {'index': index.toString()});
  }

  // 获取文件预签名
  Future<String> getPreSign(FileObj obj) async {
    String sign = "";
    // 不在本地，请求sign
    Map<String, String> headers = {
      'Authorization': token,
    };
    String fileKey = '$defaultSysPrefix/${obj.hash}.${obj.ext}';
    await NetWorkHelper.requestGet(
      preSignUrl,
      (data) {
        int code = data['code'];
        // 合并成功
        if (code == httpSuccessCode) {
          // 获取预签名
          sign = data['sign'];
          return;
        }
        // 发生错误
        MsgToast().customeToast('解析文件地址发生错误');
      },
      params: {'fileKey': fileKey},
      headers: headers,
      transform: JSONConvert.create(),
      error: (statusCode, error) {
        print(error.toString());
      },
    );
    return sign;
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
  // 获取单个文件
  getFileInfo(String uuid) async {
    Map<String, String> params = {'file_uuid': uuid};
    await NetWorkHelper.requestGet(
        fileInfoUrl,
        // success
        (data) {
          if (data['code'] == httpSuccessCode) {
            fileObjs.clear();
            fileObjs.add(FileObj.fromMap(data['info']));
            update();
            return;
          }
        },
        headers: {'Authorization': token},
        params: params,
        transform: JSONConvert.create(),
        error: (code, error) {
          MsgToast().serverErrToast();
        }
    );
  }
  // 获取路径下文件列表
  getFileObjs(bool append) async {
    if (isRoot() && banRootRefresh) {
      return;
    }
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
    String url = fileListUrl;
    Map<String, String> headers = {
      'Authorization': token,
    };
    Map<String, String> params1 = {
      'parent_uuid': curDir,
      'page': page.toString(),
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
          FileObj fileObj = FileObj.fromMap(file);
          fileObjs.add(fileObj);
        }
        // 排序
        fileObjs.sort(
          (a, b) {
            if (a.ext == 'folder' && b.ext != 'folder') {
              return -1;
            }
            if (a.ext != 'folder' && b.ext == 'folder') {
              return 1;
            }
            return a.name.compareTo(b.name);
          },
        );
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
      default:
        MsgToast().customeToast('操作类型错误');
        return () {};
    } // switch
  }

  // 上传下载
  setUpload(String dir, String path) {
    uploadDir = dir;
    uploadPath = path;
  }

  // 获取nameList
  String getNameListAsPath() {
    String res = "";
    for (int i=0; i<nameList.length; i++) {
      String name = nameList[i];
      if (i==nameList.length-1) {
        res += name;
      } else {
        res += "$name/";
      }
    }
    return res;
  }

  // 重命名
  rename(String id, String fullname) async {
    await NetWorkHelper.requestPost(
      fileRenameUrl,
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
