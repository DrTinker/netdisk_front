import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:cheetah_netdisk/isolate/manager.dart';
import 'package:cheetah_netdisk/models/trans_model.dart';
import 'dart:developer' as developer;

typedef onError = void Function(int statusCode, Object error);
typedef onSuccess = void Function(dynamic data);
typedef onProgress = void Function(int curSize, int totalSize);
// typedef onTransform = dynamic Function(dynamic body);
const statusErrorCode = -200;

class IsolateTransHelper {
  //isolate优化文件上传
  static fileUplodIsolate(
      String url, String token, onSuccess success, TransObj file,
      {Map<String, dynamic>? body,
      onError? error,
      onProgress? progress}) async {
    Map<String, dynamic> params = {};
    params['url'] = url;
    params['token'] = token;
    params['localPath'] = file.localPath;
    params['fullName'] = file.fullName;
    params['body'] = body;
    // 调用loadBalanceCommunicate
    ISOManager.loadBalanceCommunicate(fileUploadTask, (message) {
      // 发生错误
      if (message.containsKey('error')) {
        error!(statusErrorCode, message['error']);
      } else if (message.containsKey('success')) {
        // 上传成功
        success(message);
      } else {
        // 执行progress
        progress!(message['progress'], message['total']);
      }
    }, params);
  }

  static fileUploadTask(SendPort sp, Map<String, dynamic> uploadParams) async {
    // 解析参数
    String url = uploadParams['url'];
    String token = uploadParams['token'];
    String? localPath = uploadParams['localPath'];
    String? fullName = uploadParams['fullName'];
    Map<String, dynamic>? body = uploadParams['body'];

    ///创建Dio
    Dio dio = Dio();
    // 设置请求头
    dio.options.headers['Authorization'] = token;
    dio.options.headers['Content-Type'] = 'multipart/form-data';

    try {
      developer.log("fileUploadTask");
      if (body?["files"] == null) {
        body?["files"] =
            await MultipartFile.fromFile(localPath!, filename: fullName);
      } else {
        List<int> fileBytes = body?["files"];
        body?["files"] =
            await MultipartFile.fromBytes(fileBytes, filename: fullName);
      }

      // 通过FormData
      FormData formData = FormData.fromMap(body!);
      developer.log("formData: $formData");

      ///发送post
      Response response = await dio.post(url, data: formData,

          ///这里是发送请求回调函数
          ///[progress] 当前的进度
          ///[total] 总进度
          onSendProgress: (progress, total) {
        developer.log("progress: $progress, total: $total");
        // 发送进度到主进程
        sp.send({"progress": progress, "total": total});
      });
      dynamic data = response.data;
      developer.log("success get data:$data");
      sp.send({'success': data});
    } catch (e) {
      developer.log("package:net/network.dart error upload:$e");
      sp.send({"error": e.toString()});
    }
  }
}
