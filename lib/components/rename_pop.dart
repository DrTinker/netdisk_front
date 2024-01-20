// ignore_for_file: must_be_immutable, no_logic_in_create_state

import 'package:flutter/material.dart';
import 'package:cheetah_netdisk/controller/file_controller.dart';
import 'package:cheetah_netdisk/helper/parse.dart';
import 'package:get/get.dart';

class RenamePopContent extends StatefulWidget {
  RenamePopContent({super.key, required this.fc, required this.id, required this.fullName});
  FileController fc;
  String id;
  String fullName;

  @override
  State<RenamePopContent> createState() => _RenamePopContentState(fc: fc, id: id, fullName: fullName);
}

class _RenamePopContentState extends State<RenamePopContent> {
  _RenamePopContentState({required this.fc, required this.id, required this.fullName});
  FileController fc;
  final GlobalKey _formKey = GlobalKey<FormState>();
  String _name = "";
  String id;
  String fullName;
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
    List<String> names = splitName(fullName);
    String name = names[0];
    String ext = names[1];
    return TextFormField(
      textAlign: TextAlign.center,
      decoration: InputDecoration(hintText: name),
      validator: (value) {if (value==null) {return '文件名不能为空';}return null;},
      onSaved: (v) {
        if (v == "") {
          setState(() {
            _name = fullName;
          });
        } else {
          _name = '${v!}.$ext';
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
        fc.rename(id, _name);
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

class RenamePop{
  showPop(FileController fc) {
    String fileID = ""; String fileName = "";
    // 只有一个元素
    fc.taskMap.forEach((key, value) {
      fileID = key;
      fileName = '${value.name}.${value.ext}';
    });
    Get.defaultDialog(
      title: '重命名',
      content: RenamePopContent(
        fc: fc,
        id: fileID,
        fullName: fileName,
      ),
      barrierDismissible: false,
    );
  }
}