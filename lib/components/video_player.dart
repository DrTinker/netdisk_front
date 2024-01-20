import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cheetah_netdisk/conf/const.dart';
import 'package:get/get.dart';

import '../helper/file.dart';

// TODO 下载、分享、收藏
// ignore: must_be_immutable
class CustomVideoPlayer extends StatefulWidget {
  CustomVideoPlayer(this.playUrl, this.playerType,
      {super.key});
  String playUrl;
  int playerType = 0; // 0横屏(16:9) 1竖屏

  @override
  // ignore: library_private_types_in_public_api
  _CustomVideoPlayerState createState() =>
      _CustomVideoPlayerState(playUrl: playUrl, playerType: playerType);
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  _CustomVideoPlayerState(
      {required this.playUrl, required this.playerType});

  String playUrl;
  int playerType = 0; // 0横屏(16:9) 1竖屏
  double ratio = 1.0;

  late BetterPlayerController _betterPlayerController;
  late BetterPlayerDataSource _betterPlayerDataSource;

  @override
  void initState() {
    // 判断路径是否为本地文件
    BetterPlayerDataSourceType source = BetterPlayerDataSourceType.network;
    bool flag = fileExist(playUrl);
    // 若有则从本地读取
    if (flag) {
      source = BetterPlayerDataSourceType.file;
    }
    // 设定宽高比
    switch (playerType) {
      case 0:
        ratio = 16 / 9;
      case 1:
        ratio = 9 / 16;
      default:
        ratio = 1.0;
    }
    // 播放器参数
    BetterPlayerConfiguration betterPlayerConfiguration =
        BetterPlayerConfiguration(
      aspectRatio: ratio,
      fit: BoxFit.contain,
      autoPlay: true,
      allowedScreenSleep: false,
      looping: true,
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitDown,
        DeviceOrientation.portraitUp,
      ],
      controlsConfiguration: _getControllConfig()
    );
    // 配置播放源
    _betterPlayerDataSource = BetterPlayerDataSource(
      source,
      playUrl,
      cacheConfiguration: const BetterPlayerCacheConfiguration(
        useCache: true,
        preCacheSize: 10 * MB,
        maxCacheSize: 10 * MB,
        maxCacheFileSize: 10 * MB,
      ),
    );
    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    _betterPlayerController.setupDataSource(_betterPlayerDataSource);
    // _betterPlayerController.addEventsListener(_handleEvent);
    super.initState();
  }

  // @override
  // void dispose() {
  //   _betterPlayerController.removeEventsListener(_handleEvent);
  //   super.dispose();
  // }

  // void _handleEvent(BetterPlayerEvent event) {
  //   if (event.betterPlayerEventType == BetterPlayerEventType.openFullscreen) {
  //     _betterPlayerController.setOverriddenAspectRatio(9 / 16);
  //   } else if (event.betterPlayerEventType ==
  //       BetterPlayerEventType.hideFullscreen) {
  //     _betterPlayerController.setOverriddenAspectRatio(1.0);
  //   }
  // }
  BetterPlayerControlsConfiguration _getControllConfig() {
    BetterPlayerControlsConfiguration cfg;
    playerType == 0
        ? cfg = BetterPlayerControlsConfiguration(
            enableSubtitles: false,
            enableQualities: false,
            enableAudioTracks: false,
            enableFullscreen: true,
            //showControlsOnInitialize: false,
            overflowMenuCustomItems: [
                BetterPlayerOverflowMenuItem(
                  Icons.account_circle_rounded,
                  "竖屏播放",
                  () {
                    Get.offNamed('/video_portrait',
                        parameters: {'url': playUrl});
                  },
                )
              ])
        : cfg = const BetterPlayerControlsConfiguration(
            enableSubtitles: false,
            enableQualities: false,
            enableAudioTracks: false,
            enableFullscreen: false,
          );
      return cfg;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: ratio,
      child: BetterPlayer(controller: _betterPlayerController),
    );
  }
}
