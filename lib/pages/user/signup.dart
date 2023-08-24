import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../conf/const.dart';
import '../../controller/user_controller.dart';
import '../../helper/parse.dart';

class SignUpPage extends GetView<UserController> {
  final GlobalKey _formKey = GlobalKey<FormState>();
  late String _email, _password, _userName, _phone, _code;
  final _sendCode = false.obs;
  final _second = 60.obs;
  final _isObscure = true.obs;
  final _eyeColor = Colors.grey.obs;

  Widget buildTitleLine() {
    return Padding(
        padding: const EdgeInsets.only(left: 12.0, top: 4.0),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Container(
            color: Colors.black,
            width: 40,
            height: 2,
          ),
        ));
  }

  Widget buildTitle() {
    return const Padding(
        padding: EdgeInsets.all(8),
        child: Text(
          '注册',
          style: TextStyle(fontSize: 42),
        ));
  }

  Widget buildUserNameTextField() {
    return TextFormField(
      decoration: const InputDecoration(labelText: '用户名'),
      validator: (v) {
        var emailReg = RegExp(r"^[\u4e00-\u9fa5a-zA-Z0-9]{4,16}$");
        if (!emailReg.hasMatch(v!)) {
          return '用户名4-16位，可以包含中文、数字、字母';
        }
        return null;
      },
      onSaved: (v) => _userName = v!,
    );
  }

  Widget buildPhoneTextField() {
    return TextFormField(
      decoration: const InputDecoration(labelText: '手机号'),
      validator: (v) {
        var emailReg = RegExp(r"^[0-9]{0,13}");
        if (!emailReg.hasMatch(v!)) {
          return '请输入正确的手机号';
        }
        return null;
      },
      onSaved: (v) => _phone = v!,
    );
  }

  Widget buildEmailTextField() {
    return TextFormField(
      decoration: const InputDecoration(labelText: '邮箱'),
      validator: (v) {
        var emailReg = RegExp(
            r"[\w!#$%&'*+/=?^_`{|}~-]+(?:\.[\w!#$%&'*+/=?^_`{|}~-]+)*@(?:[\w](?:[\w-]*[\w])?\.)+[\w](?:[\w-]*[\w])?");
        if (!emailReg.hasMatch(v!)) {
          return '请输入正确的邮箱地址';
        }
        return null;
      },
      onChanged: (v) => _email = v,
    );
  }

  Widget buildPasswordTextField(BuildContext context) {
    return Obx(() {
      return TextFormField(
          obscureText: _isObscure.value, // 是否显示文字
          onSaved: (v) => _password = v!,
          validator: (v) {
            if (v!.isEmpty) {
              return '请输入密码';
            }
            return null;
          },
          decoration: InputDecoration(
              labelText: "密码",
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.remove_red_eye,
                  color: _eyeColor.value,
                ),
                onPressed: () {
                  // 修改 state 内部变量, 且需要界面内容更新, 需要使用 setState()
                  _isObscure.value = !_isObscure.value;
                  _eyeColor.value = (_isObscure.value
                      ? createMaterialColor(Colors.grey)
                      : createMaterialColor(
                          Theme.of(context).iconTheme.color!));
                },
              )));
    });
  }

  //倒计时
  _showTimer() {
    Timer? t;
    t = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      _second.value --;
      if (_second.value == 0) {
        t!.cancel(); //清除定时器
        _sendCode.value = false;
      }
    });
  }

  Widget buildCodeRow() {
    return Stack(
      children: [
        TextFormField(
          decoration: const InputDecoration(labelText: '验证码(区分大小写)'),
          validator: (v) {
            var emailReg = RegExp(r"^[a-zA-Z]{0,6}");
            if (!emailReg.hasMatch(v!)) {
              return '请输入正确的验证码';
            }
            return null;
          },
          onSaved: (v) => _code = v!,
        ),
        Obx(() {
          return Positioned(
            right: 0,
            top: 0,
            child: !_sendCode.value
                ? ElevatedButton(
                    style: ButtonStyle(
                        // 设置圆角
                        shape: MaterialStateProperty.all(const StadiumBorder(
                            side: BorderSide(style: BorderStyle.none)))),
                    child: Text('发送验证码'),
                    onPressed: () {
                      UserController.sendCode(_email);
                      // 设置定时器
                      _second.value = 60;
                      _sendCode.value = true;
                      _showTimer();
                    },
                  )
                : ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.grey),
                        // 设置圆角
                        shape: MaterialStateProperty.all(const StadiumBorder(
                            side: BorderSide(style: BorderStyle.none)))),
                    child: Text('${_second.value}秒后重发'),
                    onPressed: () {},
                  ),
          );
        })
      ],
    );
  }

  Widget buildSignupButton(BuildContext context) {
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
              Text('注册', style: Theme.of(context).primaryTextTheme.headline5),
          onPressed: () {
            // 表单校验通过才会继续执行
            if ((_formKey.currentState as FormState).validate()) {
              (_formKey.currentState as FormState).save();
              // 请求登录接口
              UserController.doSignup(_userName , _email, _password, _phone, _code);
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey, // 设置globalKey，用于后面获取FormStat
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: kToolbarHeight), // 距离顶部一个工具栏的高度
            buildTitle(), // Login
            buildTitleLine(), // Login下面的下划线
            const SizedBox(height: 60),
            buildEmailTextField(), // 邮箱
            const SizedBox(height: 30),
            buildUserNameTextField(), // 用户名
            const SizedBox(height: 30),
            buildPasswordTextField(context), // 输入密码
            const SizedBox(height: 30),
            buildPhoneTextField(), // 手机号
            const SizedBox(height: 30),
            buildCodeRow(), // 验证码
            const SizedBox(height: 50),
            buildSignupButton(context)
          ],
        ),
      ),
    );
  }
}
