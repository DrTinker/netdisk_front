import 'dart:async';
import 'dart:isolate';
import 'dart:developer' as developer;

import 'package:isolate/isolate_runner.dart';
import 'package:isolate/load_balancer.dart';

abstract class ISOManager {
  //提供外部首次初始化前修改
  static int isoBalanceSize = 2;

  //LoadBalancer 2个单位的线程池
  static final Future<LoadBalancer> _loadBalancer =
      LoadBalancer.create(isoBalanceSize, IsolateRunner.spawn);

  // 单向通信，子线程执行结果返回主线程
  // 通过iso在新的线程中执行future内容体
  // R 为Future返回泛型，P 为方法入参泛型
  // function 必须为 static 方法
  static Future<R> loadBalanceFuture<R, P>(
    FutureOr<R> Function(P argument) function,
    P params,
  ) async {
    final lb = await _loadBalancer;
    return lb.run<R, P>(function, params);
  }

  // 双向通信
  static loadBalanceCommunicate(
    // 在isolate中要执行的方法
    Function(SendPort sp, Map<String, dynamic> isoParams) isolateTask,
    // 主线程解析isolate返回消息的方法
    Function(Map<String, dynamic> message) msgParser,
    // 包含SendPort的参数，调用时传空，在函数中自动注入
    Map<String, dynamic> params,
  ) {
    // 主线程接收端口
    ReceivePort mainReceivePort = ReceivePort();
    // 处理参数
    params['sendPort'] = mainReceivePort.sendPort;
    // 定义isolate
    @pragma('vm:entry-point')
    void isolateHandler(Map<String, dynamic> isoParams) async {
      SendPort mainSP = isoParams['sendPort'];
      developer.log(isoParams.toString());
      // 子线程接收端口
      ReceivePort isolateReceivePort = ReceivePort();
      try {
        // 将子线程发送端口发给主线程
        mainSP.send(isolateReceivePort.sendPort);
        // 执行主线程任务
        await isolateTask(mainSP, isoParams);
      } finally {
        // 释放连接
        developer.log('连接释放');
        isolateReceivePort.close();
      }
    }

    // 将主线程发送端口发给lb
    loadBalanceFuture(isolateHandler, params);
    // 监听子线程返回数据
    mainReceivePort.listen((message) {
      if (message is SendPort) {
        developer.log("main与isolate建立双向通信");
      } else {
        developer.log('$message');
        msgParser(message);
      }
    });
  }
}
