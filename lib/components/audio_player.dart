import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_learn/components/toast.dart';
import 'package:flutter_learn/conf/const.dart';
import 'package:flutter_learn/models/file_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';

import '../helper/clipper.dart';
import '../helper/file.dart';

// TODO 播放列表 下载、分享、收藏
// ignore: must_be_immutable
class CustomAudioPlayer extends StatefulWidget {
  Map<String, FileObj> audios;
  int index;
  // 是否展示封面
  bool? showCover;

  CustomAudioPlayer({
    super.key,
    required this.audios,
    required this.index,
    this.showCover,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CustomAudioPlayerState createState() => _CustomAudioPlayerState();
}

class _CustomAudioPlayerState extends State<CustomAudioPlayer>
    with TickerProviderStateMixin {
  /// 线性动画
  late final AnimationController _repeatController;
  late final Animation<double> _animation;

  AudioPlayer _audioPlayer = AudioPlayer();

  Map<String, FileObj> audios = {};
  List<String> urls = [];
  int curIndex = 0;
  int playMode = audioCycle;
  String coverImgUrl = "";
  final List<Widget> modIcons = [
    Icon(Icons.loop),
    Icon(Icons.rocket),
    Icon(Icons.rocket_launch)
  ];

  Duration? _duration;
  Duration? _position;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerErrorSubscription;
  StreamSubscription? _playerStateSubscription;

  get _durationText => _duration?.toString().split('.').first ?? '';
  get _positionText => _position?.toString().split('.').first ?? '';

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  @override
  void dispose() {
    //释放
    _audioPlayer.dispose();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerErrorSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _repeatController.dispose();
    super.dispose();
  }

  _initAudioPlayer() async {
    audios = widget.audios;
    // 获取urls, curindex
    urls = audios.keys.toList();
    curIndex = widget.index;
    coverImgUrl = getRandomPicPath();
    // 初始化动画效果
    setAnimation();
    // 设置播放模式
    _audioPlayer.setPlayerMode(PlayerMode.mediaPlayer);
    // 设置为循环使用
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
    AudioLogger.logLevel = AudioLogLevel.error;

    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);
    });

    //监听进度
    _positionSubscription =
        _audioPlayer.onPositionChanged.listen((p) => setState(() {
              _position = p;
            }));

    //播放完成
    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((event) {
      switch (playMode) {
        case audioCycle:
          _next();
        case audioLoop:
          // do nothing
          _play();
        case audioRandom:
          _random();
      }
      setState(() {
        _position = const Duration(seconds: 0);
      });
    });

    //监听报错
    _playerErrorSubscription = _audioPlayer.onLog.listen((msg) {
      (Object e, [StackTrace? stackTrace]) => setState(() {
            print('e: $e, trace: $stackTrace');
            _duration = const Duration(seconds: 0);
            _position = const Duration(seconds: 0);
          });
    });

    //播放状态改变
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        if (state == PlayerState.playing) {
          _repeatController.repeat();
        } else {
          _repeatController.stop();
        }
      });
    });
    // 配置播放源
    bool flag = await _getAudioSource();
    if (!flag) {
      MsgToast().customeToast('播放源发生错误，无法继续播放');
      return;
    }
    // 初始化完成则播放
    _play();
  }

  // 获取播放源
  Future<bool> _getAudioSource() async {
    bool res = true;
    try {
      String url = urls[curIndex];
      bool flag = fileExist(url);
      // 若有则从本地读取
      if (flag) {
        await _audioPlayer.setSourceDeviceFile(url);
      } else {
        await _audioPlayer.setSourceUrl(url);
      }
    } catch (e) {
      print('audio player: $e');
      res = false;
    }
    return res;
  }

  //开始播放
  _play() async {
    await _audioPlayer.resume();
    _audioPlayer.setPlaybackRate(1.0);
  }

  //暂停
  _pause() async {
    await _audioPlayer.pause();
  }

  //停止播放
  _stop() async {
    await _audioPlayer.stop();
  }

  // 切换下一首
  _next() async {
    if (urls.isEmpty) {
      return;
    }
    setState(() {
      curIndex = (curIndex + 1) % urls.length;
    });
    bool flag = await _getAudioSource();
    if (!flag) {
      MsgToast().customeToast('播放源发生错误，无法继续播放');
      return;
    }
    _play();
  }

  // 切换上一首
  _prev() async {
    if (urls.isEmpty) {
      return;
    }
    curIndex--;
    if (curIndex < 0) {
      setState(() {
        curIndex = urls.length - 1;
      });
    }
    bool flag = await _getAudioSource();
    if (!flag) {
      MsgToast().customeToast('播放源发生错误，无法继续播放');
      return;
    }
    _play();
  }

  // 随机选择一首
  _random() async {
    if (urls.isEmpty) {
      return;
    }
    setState(() {
      curIndex = Random().nextInt(urls.length - 1);
    });
    bool flag = await _getAudioSource();
    if (!flag) {
      MsgToast().customeToast('播放源发生错误，无法继续播放');
      return;
    }
    _play();
  }

  // c从列表选择一首
  _select(int index) async {
    setState(() {
      curIndex = index;
    });
    bool flag = await _getAudioSource();
    if (!flag) {
      MsgToast().customeToast('播放源发生错误，无法继续播放');
      return;
    }
    _play();
  }

  // 移除一首
  _remove(int index) async {
    // 删除
    setState(() {
      String removeUrl = urls.removeAt(index);
      audios.remove(removeUrl);
    });
    // 判断被删除对象
    if (index == curIndex) {
      _random();
    } else {
      // do nothing
    }
  }

  // 设置封面
  Widget _buildAudioCoverWidget() {
    Image image = Image.asset(
      coverImgUrl,
      fit: BoxFit.cover,
    );
    // 获取图片
    var rotateImage = RotationTransition(turns: _animation, child: image);
    var ring = SizedBox(
      width: 220,
      height: 220,
      child: ClipPath(
        clipper: MyPathClipper(),
        child: rotateImage,
      ),
    );
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(60, 60, 20, 20),
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(
                sigmaX: 10, sigmaY: 10, tileMode: TileMode.decal),
            child: ring,
          ),
        ),
        ring,
      ],
    );
  }

  setAnimation() {
    // 设置旋转动画
    // 动画持续时间是 3秒，此处的this指 TickerProviderStateMixin
    _repeatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )
      //  添加动画监听
      ..addListener(() {
        // 获取动画当前的状态
        var status = _repeatController.status;
        if (status == AnimationStatus.completed) {
          // 延时1秒
          Future.delayed(const Duration(seconds: 1), () {
            //从0开始向前播放
            _repeatController.forward(from: 0.0);
          });
        }
      })
      ..forward();

    _animation = Tween<double>(begin: 0, end: 1).animate(_repeatController);
  }

  // 音乐播放进度条
  Widget _getSliderBar() {
    return ListTile(
      title: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Stack(
          children: [
            Slider(
              onChanged: (v) {
                try {
                  final position = v * _duration!.inMilliseconds;
                  _audioPlayer.seek(Duration(milliseconds: position.round()));
                } catch (e) {
                  MsgToast().customeToast('资源还未就绪');
                }
              },
              value: (_position != null &&
                      _duration != null &&
                      _position!.inMilliseconds > 0 &&
                      _position!.inMilliseconds < _duration!.inMilliseconds)
                  ? _position!.inMilliseconds / _duration!.inMilliseconds
                  : 0.0,
            ),
          ],
        ),
      ),
      subtitle: _duration != null
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${_positionText ?? ''}'),
                Text('${_durationText ?? ''}')
              ],
            )
          : null,
    );
  }

  // 生成音频列表内容
  List<Widget> _getListContent() {
    List<Widget> res = [
      const SizedBox(
        height: 20,
      )
    ];
    List<FileObj> elements = audios.values.toList();
    for (int i = 0; i < elements.length; i++) {
      FileObj audio = elements[i];
      Widget element = Slidable(
        key: ValueKey("$i"),
        //滑动方向
        direction: Axis.horizontal,
        // The end action pane is the one at the right or the bottom side.
        endActionPane: ActionPane(
          motion: ScrollMotion(),
          dismissible: DismissiblePane(onDismissed: () {
            _remove(i);
          }),
          children: [
            SlidableAction(
              // An action can be bigger than the others.
              flex: 2,
              onPressed: (BuildContext ctx) {},
              backgroundColor: Color.fromARGB(255, 227, 64, 24),
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: '左滑移除播放列表',
            ),
          ],
        ),
        //列表显示的子Item
        child: ListTile(
          leading: audio.icon,
          title: Text(audio.name),
          onTap: () {
            _select(i);
            Get.back();
          },
        ),
      );
      res.add(element);
    }
    return res;
  }

  // 音频列表弹出层
  _getAudioListPop() {
    // 构建弹出层
    Get.bottomSheet(
      Container(
        height: 500,
        color: Colors.white,
        child: ListView(
          children: _getListContent(),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  // 播放器控制列表
  Widget _getIconBtns() {
    // 左边切换播放模式
    Widget modeIcon = IconButton(
      icon: modIcons[playMode],
      onPressed: () {
        setState(() {
          playMode = (playMode + 1) % 3;
        });
      },
    );
    // 中间三个
    Widget playBtns = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            onPressed: () {
              _prev();
            },
            icon: Icon(Icons.keyboard_double_arrow_left)),
        IconButton(
            icon: (_audioPlayer.state == PlayerState.paused ||
                    _audioPlayer.state == PlayerState.stopped)
                ? const Icon(Icons.play_arrow)
                : const Icon(Icons.pause),
            onPressed: () {
              (_audioPlayer.state == PlayerState.paused ||
                      _audioPlayer.state == PlayerState.stopped)
                  ? _play()
                  : _pause();
            }),
        IconButton(
            onPressed: () {
              _next();
            },
            icon: Icon(Icons.keyboard_double_arrow_right)),
      ],
    );
    // 播放列表按钮
    Widget listIcon = IconButton(
      icon: Icon(Icons.list),
      onPressed: () {
        _getAudioListPop();
      },
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        modeIcon,
        playBtns,
        listIcon,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // 获取图片
        (widget.showCover == null || widget.showCover == false)
            ? _buildAudioCoverWidget()
            : const SizedBox(
                height: 5,
              ),
        // 歌曲名称
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            audios[urls[curIndex]]!.name,
            style: const TextStyle(fontSize: 24),
          ),
        ),
        // 进度条
        _getSliderBar(),
        // 播放按钮
        _getIconBtns(),
      ],
    );
  }
}
