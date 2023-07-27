import 'package:flutter/material.dart';
import 'package:flutter_learn/binding/file_binding.dart';
import 'package:flutter_learn/binding/trans_binding.dart';
import 'package:flutter_learn/pages/file/audio_view.dart';
import 'package:flutter_learn/pages/file/file_view.dart';
import 'package:flutter_learn/pages/file/pic_view.dart';
import 'package:flutter_learn/pages/file/video_portrait_view.dart';
import 'package:flutter_learn/pages/file/video_view.dart';
import 'package:flutter_learn/pages/share/share_view.dart';
import 'package:flutter_learn/pages/trans/trans_view.dart';
import 'package:flutter_learn/pages/user/forget.dart';
import 'package:flutter_learn/pages/user/info_view.dart';
import 'package:flutter_learn/pages/user/signup.dart';
import 'package:get/get.dart';

import 'package:flutter_learn/pages/user/login.dart';

import 'binding/audio_binding.dart';
import 'binding/pic_binding.dart';
import 'binding/video_binding.dart';
import 'helper/check.dart';
import 'middleware/token.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // 上传按钮在底部导航栏，上传数据为全局共享
    // TransController tc = TransController(); tc: tc,
    return GetMaterialApp(
        debugShowCheckedModeBanner: false, // 不显示右上角的 debug
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        // 注册路由表
        initialRoute: '/file',
        getPages: [
          GetPage(name: "/forget", page: () => const ForgetPage()),
          GetPage(name: "/signup", page: () => const SignUpPage()),
          GetPage(name: "/login", page: () => const LoginPage(title: "登录")),
          GetPage(name: "/file", page: () => FilePage(), binding: FileBinding(), middlewares: [LoginCheckMiddleware()]),
          GetPage(name: "/pic", page: () => const PicturePage(), binding: PicBinding()),
          GetPage(name: "/audio", page: () => AudioPage(), binding: AudioBinding()),
          GetPage(name: "/video", page: () => const VideoPage(), binding: VideoBinding()),
          GetPage(name: "/video_portrait", page: () => const VideoPortraitPage(), binding: VideoBinding()),
          GetPage(name: '/trans', page: () => TransPage(), binding: TransBinding()),
          GetPage(name: '/share', page: () => const SharePage()),
          GetPage(name: '/user_info', page: () => const UserInfoPage()),
        ],
        routingCallback: (routing) => {
          loginCheck(routing?.current),
        },
      );
  }
}


