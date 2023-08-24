import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ShareCancelNotice extends StatelessWidget {
  const ShareCancelNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
      SizedBox(height: 160,),
      Center(child: Text('分享已经被取消',
      style: TextStyle(fontSize: 30),),),
      Spacer(),
      TextButton(onPressed: (){
        Get.offNamed('/share');
      }, 
          child: Text('返回分享界面', style: TextStyle(fontSize: 20),),),
          SizedBox(height: 40,)
    ],),
    );
  }
}