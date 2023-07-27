import 'package:flutter/material.dart';
import 'package:flutter_learn/components/audio_player.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("音频播放"),
      ),
      body: Column(
        children: [
          
        ],
      ),
    );
  }
}
