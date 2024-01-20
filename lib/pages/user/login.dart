// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';

import 'package:cheetah_netdisk/controller/user_controller.dart';
import 'package:cheetah_netdisk/helper/parse.dart';

import 'package:get/get.dart';

import '../../components/toast.dart';

// ignore: must_be_immutable
class LoginPage extends GetView<UserController> {
  final GlobalKey _formKey = GlobalKey<FormState>();
  String? _email, _password;
  final _isObscure = true.obs;
  final _eyeColor = Colors.grey.obs;
  final List _loginMethod = [
    {
      "title": "facebook",
      "icon": Icons.facebook,
    },
    {
      "title": "google",
      "icon": Icons.fiber_dvr,
    },
    {
      "title": "twitter",
      "icon": Icons.account_balance,
    },
  ];
  // 检测退出逻辑
  DateTime lastPopTime = DateTime.now();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // // 读取controller
    // UserController uc = Get.find<UserController>();
    // 获取参数
    Map<String, dynamic> data = Get.parameters;
    if (data.containsKey('email')) {
      _email = data['email'];
    }
    if (data.containsKey('password')) {
      _password = data['password'];
    }
    return WillPopScope(
      child: Scaffold(
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
              buildEmailTextField(), // 输入邮箱
              const SizedBox(height: 30),
              buildPasswordTextField(context), // 输入密码
              buildForgetPasswordText(context), // 忘记密码
              const SizedBox(height: 60),
              buildLoginButton(context), // 登录按钮
              const SizedBox(height: 40),
              // buildOtherLoginText(), // 其他账号登录
              // buildOtherMethod(context), // 其他登录方式
              buildRegisterText(context), // 注册
            ],
          ),
        ),
      ),
      onWillPop: () async {
        // 根目录执行退出app逻辑
        if (DateTime.now().difference(lastPopTime) > Duration(seconds: 1)) {
          lastPopTime = DateTime.now();
          MsgToast().customeToast("再按一次退出");
          return Future.value(false);
        } else {
          lastPopTime = DateTime.now();
          // 退出app
          return Future.value(true);
        }
      },
    );
  }

  Widget buildRegisterText(context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('没有账号?'),
            GestureDetector(
              child: const Text('点击注册', style: TextStyle(color: Colors.green)),
              onTap: () {
                Get.toNamed('/signup');
              },
            )
          ],
        ),
      ),
    );
  }

  Widget buildOtherMethod(context) {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: _loginMethod
          .map((item) => Builder(builder: (context) {
                return IconButton(
                    icon: Icon(item['icon'],
                        color: Theme.of(context).iconTheme.color),
                    onPressed: () {
                      //TODO: 第三方登录方法
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('${item['title']}登录'),
                            action: SnackBarAction(
                              label: '取消',
                              onPressed: () {},
                            )),
                      );
                    });
              }))
          .toList(),
    );
  }

  Widget buildOtherLoginText() {
    return const Center(
      child: Text(
        '其他账号登录',
        style: TextStyle(color: Colors.grey, fontSize: 14),
      ),
    );
  }

  Widget buildLoginButton(BuildContext context) {
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
              Text('登录', style: Theme.of(context).primaryTextTheme.headline5),
          onPressed: () async{
            // 表单校验通过才会继续执行
            if ((_formKey.currentState as FormState).validate()) {
              (_formKey.currentState as FormState).save();
              // 请求登录接口
              await UserController.doLogin(_email!, _password);
            }
          },
        ),
      ),
    );
  }

  Widget buildForgetPasswordText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () {
            Get.toNamed('/forget');
          },
          child: const Text("忘记密码？",
              style: TextStyle(fontSize: 14, color: Colors.grey)),
        ),
      ),
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
              hintText: _password,
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

  Widget buildEmailTextField() {
    return TextFormField(
      decoration: InputDecoration(labelText: '邮箱', hintText: _email),
      validator: (v) {
        var emailReg = RegExp(
            r"[\w!#$%&'*+/=?^_`{|}~-]+(?:\.[\w!#$%&'*+/=?^_`{|}~-]+)*@(?:[\w](?:[\w-]*[\w])?\.)+[\w](?:[\w-]*[\w])?");
        if (!emailReg.hasMatch(v!)) {
          return '请输入正确的邮箱地址';
        }
        return null;
      },
      onSaved: (v) => _email = v!,
    );
  }

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
          '登录',
          style: TextStyle(fontSize: 42),
        ));
  }
}
