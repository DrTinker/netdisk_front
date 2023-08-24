import 'package:flutter/material.dart';
import 'package:cheetah_netdesk/binding/file_binding.dart';
import 'package:cheetah_netdesk/binding/get_share_binding.dart';
import 'package:cheetah_netdesk/binding/share_binding.dart';
import 'package:cheetah_netdesk/binding/share_code_binding.dart';
import 'package:cheetah_netdesk/binding/share_detail_binding.dart';
import 'package:cheetah_netdesk/binding/trans_binding.dart';
import 'package:cheetah_netdesk/binding/user_info_binding.dart';
import 'package:cheetah_netdesk/pages/file/audio_view.dart';
import 'package:cheetah_netdesk/pages/file/file_view.dart';
import 'package:cheetah_netdesk/pages/file/pic_view.dart';
import 'package:cheetah_netdesk/pages/file/video_portrait_view.dart';
import 'package:cheetah_netdesk/pages/file/video_view.dart';
import 'package:cheetah_netdesk/pages/share/get_share_view.dart';
import 'package:cheetah_netdesk/pages/share/share_cancel_notice.dart';
import 'package:cheetah_netdesk/pages/share/share_code_view.dart';
import 'package:cheetah_netdesk/pages/share/share_detail.dart';
import 'package:cheetah_netdesk/pages/share/share_view.dart';
import 'package:cheetah_netdesk/pages/trans/trans_view.dart';
import 'package:cheetah_netdesk/pages/user/forget.dart';
import 'package:cheetah_netdesk/pages/user/info_view.dart';
import 'package:cheetah_netdesk/pages/user/signup.dart';
import 'package:get/get.dart';

import 'package:cheetah_netdesk/pages/user/login.dart';

import 'binding/audio_binding.dart';
import 'binding/pic_binding.dart';
import 'binding/video_binding.dart';
import 'helper/check.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        debugShowCheckedModeBanner: false, // 不显示右上角的 debug
        title: '猎豹网盘',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        // 注册路由表
        initialRoute: '/login',
        getPages: [
          GetPage(name: "/forget", page: () => const ForgetPage()),
          GetPage(name: "/signup", page: () => SignUpPage(),),
          GetPage(name: "/login", page: () => LoginPage(),),
          GetPage(name: "/file", page: () => FilePage(), binding: FileBinding(), ),
          GetPage(name: "/pic", page: () => const PicturePage(), binding: PicBinding()),
          GetPage(name: "/audio", page: () => AudioPage(), binding: AudioBinding()),
          GetPage(name: "/video", page: () => const VideoPage(), binding: VideoBinding()),
          GetPage(name: "/video_portrait", page: () => const VideoPortraitPage(), binding: VideoBinding()),
          GetPage(name: '/trans', page: () => TransPage(), binding: TransBinding()),
          GetPage(name: '/share', page: () => SharePage(), binding: ShareBinding()),
          GetPage(name: '/code', page: () => ShareCodePage(), binding: ShareCodeBinding()),
          GetPage(name: '/share_detail', page: () => ShareDetailPage(), binding: ShareDetailBinding()),
          GetPage(name: '/get_share', page: () => GetSharePage(), binding: GetShareBinding()),
          GetPage(name: '/share_cancel', page: () => const ShareCancelNotice()),
          GetPage(name: '/user_info', page: () => UserInfoPage(), binding: UserInfoBinding()),
        ],
        routingCallback: (routing) => {
          loginCheck(routing?.current),
        },
      );
  }
}


