// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:cheetah_netdesk/controller/file_controller.dart';
import 'package:get/get.dart';

class MkdirPopContent extends StatefulWidget {
  MkdirPopContent({super.key, required this.fc});
  FileController fc;

  @override
  State<MkdirPopContent> createState() => _MkdirPopContentState(fc: fc);
}

class _MkdirPopContentState extends State<MkdirPopContent> {
  _MkdirPopContentState({required this.fc});
  FileController fc;
  final GlobalKey _formKey = GlobalKey<FormState>();
  String _name = "";
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Image.asset(
            'assets/images/folder.png',
            height: 60,
            width: 60,
          ),
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
      decoration: const InputDecoration(hintText: '新建文件夹'),
      validator: (value) {return null;},
      onSaved: (v) {
        if (v == "") {
          setState(() {
            _name = "新建文件夹";
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
      child: Text('创建'),
      onPressed: () {
        // 调用接口
        if ((_formKey.currentState as FormState).validate()) {
          (_formKey.currentState as FormState).save();
        }
        print('创建：$_name');
        fc.mkDir(_name);
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

class MkdirPop {
  showPop(FileController fc) {
    Get.defaultDialog(
      title: '新建文件夹',
      content: MkdirPopContent(
        fc: fc,
      ),
      barrierDismissible: false,
    );
  }
}
