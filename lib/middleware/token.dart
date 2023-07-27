import 'package:flutter/material.dart';
import 'package:flutter_learn/pages/user/login.dart';
import 'package:get/get.dart';

import '../conf/const.dart';
import '../helper/storage.dart';

class LoginCheckMiddleware extends GetMiddleware {
  @override
  // TODO: implement priority
  int? get priority => -1;
  //重定向，当正在搜索被调用路由的页面时，将调用该函数
  @override
  RouteSettings? redirect(String? route) {
    var store = SyncStorage();
    if (!store.hasKey(userToken) && !store.hasKey(userStartDir)) {
      return const RouteSettings(name: '/login');
    }
    return null;
  }

//创建任何内容之前调用此函数
  @override
  GetPage? onPageCalled(GetPage? page) {
    var store = SyncStorage();
    if (!store.hasKey(userToken) && !store.hasKey(userStartDir)) {
      return GetPage(name: '/login', page: () => const LoginPage(title: "登录"));
    }
    return page;
  }

  //这个函数将在绑定初始化之前被调用。在这里您可以更改此页面的绑定。
  @override
  List<Bindings>? onBindingsStart(List<Bindings>? bindings) {
    return bindings;
  }

//此函数将在绑定初始化后立即调用。在这里，您可以在创建绑定之后和创建页面小部件之前执行一些操作
  @override
  GetPageBuilder? onPageBuildStart(GetPageBuilder? page) {
    return page;
  }

  //该函数将在调用 GetPage.page 函数后立即调用，并为您提供函数的结果。并获取将显示的小部件
  @override
  Widget onPageBuilt(Widget page) {
    return page;
  }

//此函数将在处理完页面的所有相关对象（控制器、视图等）后立即调用
  @override
  void onPageDispose() {
    super.onPageDispose();
  }
}
