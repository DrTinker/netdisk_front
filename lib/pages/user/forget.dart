import 'package:flutter/material.dart';
import 'package:cheetah_netdisk/components/toast.dart';
import 'package:cheetah_netdisk/controller/user_controller.dart';

class ForgetPage extends StatefulWidget {
  const ForgetPage({super.key});

  @override
  State<ForgetPage> createState() => _ForgetPageState();
}

class _ForgetPageState extends State<ForgetPage> {
  final GlobalKey _formKey = GlobalKey<FormState>();
  String? _email, _phone;

  Widget _buildEmailBlanks() {
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

  Widget _buildPhoneBlanks() {
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

  Widget _buildSendButton(BuildContext context) {
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
              Text('发送邮件', style: Theme.of(context).primaryTextTheme.headline5),
          onPressed: () {
            // 表单校验通过才会继续执行
            if ((_formKey.currentState as FormState).validate()) {
              (_formKey.currentState as FormState).save();
              // 发送邮件
              UserController.sendForget(_email!, _phone!);
            } else {
              MsgToast().customeToast('请填写正确的邮箱和手机号');
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('找回密码'),
      ),
      body: Form(key: _formKey, child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
        const SizedBox(height: kToolbarHeight), // 距离顶部一个工具栏的高度
        const SizedBox(height: 60,),
        _buildEmailBlanks(),
        const SizedBox(height: 20,),
        _buildPhoneBlanks(),
        const SizedBox(height: 40,),
        _buildSendButton(context),
        const SizedBox(height: 60,),
      ]),),
    );
  }
}