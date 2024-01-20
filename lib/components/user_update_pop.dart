// ignore_for_file: must_be_immutable, no_logic_in_create_state

import 'package:flutter/material.dart';
import 'package:cheetah_netdisk/controller/user_controller.dart';
import 'package:get/get.dart';

class UpdatePopContent extends StatefulWidget {
  UpdatePopContent({super.key, required this.uc});
  UserController uc;

  @override
  State<UpdatePopContent> createState() => _UpdatePopContentState();
}

class _UpdatePopContentState extends State<UpdatePopContent> {

  final GlobalKey _formKey = GlobalKey<FormState>();
  String _name = "";

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          SizedBox(height: 10,),
          widget.uc.user!.avatar,
          const SizedBox(height: 20),
          buildNameTextField(),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildConfirmButton(),
              buildCancelButton(),
            ],
          )
        ],
      )
    );
  }

  Widget buildNameTextField() {
    return TextFormField(
      textAlign: TextAlign.center,
      decoration: InputDecoration(hintText: widget.uc.user!.userName),
      validator: (value) {if (value==null) {return '文件名不能为空';}return null;},
      onSaved: (v) {
        if (v == "") {
          setState(() {
            _name = widget.uc.user!.userName;
          });
        } else {
          _name = v!;
        }
      },
    );
  }

  Widget buildConfirmButton() {
    return ElevatedButton(
      style: ButtonStyle(
          // 设置圆角
          shape: MaterialStateProperty.all(
              const StadiumBorder(side: BorderSide(style: BorderStyle.none)))),
      child: Text('更改'),
      onPressed: () async{
        // 调用接口
        if ((_formKey.currentState as FormState).validate()) {
          (_formKey.currentState as FormState).save();
        }
        widget.uc.doRename(_name);
        Get.back();
      },
    );
  }

  Widget buildCancelButton() {
    return ElevatedButton(
      style: ButtonStyle(
          // 设置圆角
          shape: MaterialStateProperty.all(
              const StadiumBorder(side: BorderSide(style: BorderStyle.none)))),
      child: Text('取消'),
      onPressed: () {
        Get.back();
      },
    );
  }
}

class UserUpdatePop{
  showPop(UserController uc) {
    Get.defaultDialog(
      title: '修改用户信息',
      content: UpdatePopContent(
        uc: uc,
      ),
      barrierDismissible: false,
    );
  }
}