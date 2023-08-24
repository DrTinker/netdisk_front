// ignore_for_file: camel_case_types

import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:cheetah_netdesk/components/toast.dart';
import 'package:cheetah_netdesk/conf/const.dart';
import 'package:cheetah_netdesk/controller/user_controller.dart';
import 'package:cheetah_netdesk/helper/convert.dart';
import 'package:cheetah_netdesk/helper/storage.dart';
import 'package:cheetah_netdesk/models/trans_model.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

typedef onError = void Function(int statusCode, Object error);
typedef onSuccess = void Function(dynamic data);
typedef onProgress = void Function(int curSize, int totalSize);
// typedef onTransform = dynamic Function(dynamic body);
const statusErrorCode = -200;

// get参数在url末尾拼接，post参数写入body中
class NetWorkHelper {
  //get request
  static Future requestGet(String url, onSuccess success,
      {Map<String, String>? params,
      Map<String, String>? headers,
      Convert? transform,
      onError? error}) async {
    url = joinParams(params, url);
    try {
      Uri uri = Uri.parse(url);
      http.Response response = await http.get(uri, headers: headers);
      checkResponseData(response, transform, success, error);
    } catch (e) {
      developer.log("package:net/network.dart error get data:$e");
      if (error != null) {
        error(statusErrorCode, e.toString());
      }
    }
  }

  ///Stitching parameters(拼接参数)
  static String joinParams(Map<String, String>? params, String url) {
    if (params != null && params.isNotEmpty) {
      StringBuffer stringBuffer = StringBuffer("?");
      params.forEach((key, value) {
        stringBuffer.write("$key=$value&");
      });
      String paramStr = stringBuffer.toString();
      paramStr = paramStr.substring(0, paramStr.length - 1);
      url = url + paramStr;
    }
    return url;
  }

  ///post request
  static Future<dynamic> requestPost(String url, onSuccess success,
      {Map<String, String>? params,
      Map<String, dynamic>? body,
      Map<String, String>? headers,
      Convert? transform,
      onError? error}) async {
    url = joinParams(params, url);
    // 判断是否为json类型
    String bodyJson = "";
    bool isJson = headers?['Content-Type'] == 'application/json';
    if (isJson) {
      bodyJson = JSONConvert().encodeJson(body);
    }
    try {
      Uri uri = Uri.parse(url);
      http.Response response = await http.post(
        uri,
        headers: headers,
        body: isJson ? bodyJson : body,
      );
      checkResponseData(response, transform, success, error);
    } catch (e) {
      developer.log("package:net/network.dart error post data:$e");
      if (error != null) {
        error(statusErrorCode, e.toString());
      }
    }
  }

  //dio 实现文件上传
  static fileUplod(
      String url, String token, onSuccess success, TransObj file,
      {Map<String, dynamic>? body,
      onError? error,
      onProgress? progress}) async {
    ///创建Dio
    Dio dio = Dio();
    // 设置请求头
    dio.options.headers['Authorization'] = token;
    dio.options.headers['Content-Type'] = 'multipart/form-data';

    try {
      if (body?["files"] == null) {
        body?["files"] = await MultipartFile.fromFile(file.localPath,
            filename: file.fullName);
      } else {
        List<int> fileBytes = body?["files"];
        body?["files"] =
            await MultipartFile.fromBytes(fileBytes, filename: file.fullName);
      }

      // 通过FormData
      FormData formData = FormData.fromMap(body!);

      ///发送post
      Response response = await dio.post(url,
          data: formData,

          ///这里是发送请求回调函数
          ///[progress] 当前的进度
          ///[total] 总进度
          onSendProgress: progress);

      ///服务器响应结果
      checkDioResp(response, success, error);
    } catch (e) {
      developer.log("package:net/network.dart error upload:$e");
      if (error != null) {
        error(statusErrorCode, e.toString());
      }
    }
  }

  // dio实现文件下载
  static Future<dynamic> fileDownload(
      String url, onSuccess success, String savePath,
      {Map<String, dynamic>? param,
      TransObj? file,
      String? token,
      String? range,
      Convert? transform,
      onError? error,
      onProgress? progress}) async {
    ///创建Dio
    Dio dio = Dio();
    // 设置请求头
    dio.options.headers['Authorization'] = token;
    dio.options.headers['Content-Type'] = 'multipart/form-data';
    dio.options.headers['Range'] = range;

    try {
      ///发送post
      Response response = await dio.download(
        url,
        savePath,
        queryParameters: param,
        onReceiveProgress: progress,
        deleteOnError: true, // 出错删除已下载的文件
      );

      ///服务器响应结果
      checkDownloadResp(response, savePath, success, error);
    } catch (e) {
      developer.log("package:net/network.dart error upload:$e");
      if (error != null) {
        error(statusErrorCode, e.toString());
      }
    }
  }

  ///处理response
  static void checkResponseData(http.Response response, Convert? transform,
      onSuccess success, onError? error) {
    if (response.statusCode == 200) {
      dynamic data = response.body;
      if (transform != null) {
        data = transform.transform(data);
      }
      developer.log("success get data:$data");
      success(data);
    } else {
      developer.log('Request get failed with status: ${response.statusCode}');
      // 未登录
      if (response.statusCode == 401) {
        refreshToken();
      }
      if (error != null) {
        error(response.statusCode, response.body);
      }
    }
  }

  static void checkDioResp(Response response,
      onSuccess success, onError? error) {
    if (response.statusCode == 200) {
      dynamic data = response.data;
      developer.log("success get data:$data");
      success(data);
    } else {
      developer.log('Request get failed with status: ${response.statusCode}');
      // 未登录
      if (response.statusCode == 401) {
        refreshToken();
      }
      
      if (error != null) {
        error(response.statusCode!, "fail get data");
      }
    }
  }

  static void checkDownloadResp(
      Response response, String savePath, onSuccess success, onError? error) {
    // 全部下载或者部分下载
    if (response.statusCode == 200 || response.statusCode == 206) {
      dynamic data = response.data;
      developer.log("save to $savePath");
      success(data);
    } else {
      developer.log('Request get failed with status: ${response.statusCode}');
      // 未登录
      if (response.statusCode == 401) {
        refreshToken();
      }
      if (error != null) {
        error(response.statusCode!, "fail get data");
      }
    }
  }

  static refreshToken() async{
    // 读取磁盘的email和pwd
    var ps = PersistentStorage();
    String email = await ps.getStorage(userEmail);
    String pwd = await ps.getStorage(userPwd);
    // 请求登录接口
    bool flag = await UserController.doLogin(email, pwd);
    // 尝试10次
    for (int i=0; i<10 && !flag; i++) {
      flag = await UserController.doLogin(email, pwd, navi: false);
    }
    // 还没成功
    if (!flag) {
      MsgToast().customeToast('登录失效了，请尝试退出app重新登录');
    }
  }
}

Future<String> getFileHash(String filePath) async {
  final file = File(filePath);
  final fileLength = file.lengthSync();

  final fileBytes = file.readAsBytesSync().buffer.asUint8List();
  final hash = md5.convert(fileBytes.buffer.asUint8List()).toString();
  return hash;
}
