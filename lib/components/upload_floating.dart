// ignore_for_file: no_logic_in_create_state

import 'package:flutter/material.dart';

import '../controller/trans_controller.dart';
import 'openFile_pop.dart';

class UploadFloating extends StatefulWidget {
  UploadFloating({super.key, required this.tc});
  TransController tc;

  @override
  State<UploadFloating> createState() => _UploadFloatingState(tc: tc);
}

class _UploadFloatingState extends State<UploadFloating> {
  _UploadFloatingState({required this.tc});
  TransController tc;
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
        //悬浮按钮
        child: Icon(Icons.add),
        onPressed: () {
          OpenFilePop().showPop(tc);
        }
    );
  }
}
