import 'package:flutter/material.dart';
import 'package:cheetah_netdisk/components/toast.dart';
import 'package:cheetah_netdisk/controller/share_controller.dart';
import 'package:get/get.dart';

import '../../controller/file_controller.dart';

class ShareCodePage extends GetView<ShareController> {
  ShareCodePage({super.key});

  // 表单
  final GlobalKey _formKey = GlobalKey<FormState>();
  String? _code;

  Widget _buildUserName(ShareController sc) {
    return Text(
      sc.curOwner!=null ? sc.curOwner!.userName: "未知用户",
      style: const TextStyle(fontSize: 20),
    );
  }

  Widget _buildCodeInput() {
    return Container(
      margin: const EdgeInsets.only(left: 10),
      width: 270,
      decoration: BoxDecoration(
          color: Color.fromARGB(255, 234, 230, 214),
          border: Border.all(color: Colors.white60, width: 0.5),
          borderRadius: BorderRadius.circular((20.0))),
      child: TextFormField(
          validator: (value) {
            if (value == null || value.length > 4) {
              return '提取码无效';
            }
            return null;
          },
          onSaved: (v) {
            _code = v!;
          },
          decoration: const InputDecoration(
              hintText: "输入四位口令获取文件",
              prefixIcon: Icon(Icons.search),
              contentPadding: EdgeInsets.only(top: 10, left: 10),
              border: InputBorder.none)),
    );
  }

  Widget _buildSubmitButton(BuildContext context, ShareController sc) {
    return Align(
      child: SizedBox(
        height: 45,
        width: 270,
        child: ElevatedButton(
          style: ButtonStyle(
              // 设置圆角
              shape: MaterialStateProperty.all(const StadiumBorder(
                  side: BorderSide(style: BorderStyle.none)))),
          child:
              Text('获取文件', style: Theme.of(context).primaryTextTheme.headline5),
          onPressed: () {
            // 表单校验通过才会继续执行
            if ((_formKey.currentState as FormState).validate()) {
              (_formKey.currentState as FormState).save();
              if (sc.curShare == null) {
                MsgToast().serverErrToast();
                return;
              }
              // 口令错误
              if (_code != sc.curShare!.code) {
                MsgToast().customeToast('口令错误');
                return;
              }
              // 口令正确跳转
              // 创建一个空的fc
              FileController fc = FileController();
              // 禁止根目录刷新
              fc.banRootRefresh = true;
              Get.put(fc, tag: 'get_share');
              Get.toNamed('get_share');
            }
          },
        ),
      ),
    );
  }

  Widget _buildExpireLayout() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
        Image.asset('assets/images/unknow.png', width: 100, height: 100,),
        SizedBox(height: 20,),
        Text(
          "分享已失效或者被取消",
          style: const TextStyle(fontSize: 20),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 获取sc
    ShareController sc = Get.find<ShareController>();
    Widget icon = Image.asset('assets/random/qq.jpg', height: 60, width: 60,);
    Widget avatar = ClipOval(child: icon,);

    return Scaffold(
        appBar: AppBar(title: Text('口令验证')),
        body: sc.curShare != null 
          ? Form(
          key: _formKey,
          child: Align(
          alignment: FractionalOffset(0.4, 0.4),
          child: GetBuilder<ShareController>(
            init: sc,
            builder: (controller) {
            return Column(mainAxisSize: MainAxisSize.min, children: [
            // 分享者信息
            sc.curOwner!=null ? sc.curOwner!.avatar : avatar,
            SizedBox(
              height: 10,
            ),
            _buildUserName(controller),
            SizedBox(
              height: 50,
            ),
            // 输入框
            _buildCodeInput(),
            SizedBox(
              height: 20,
            ),
            // 提交按钮
            _buildSubmitButton(context, controller)
          ]);
          },)
        ),)
        : _buildExpireLayout()
    );
  }
}
