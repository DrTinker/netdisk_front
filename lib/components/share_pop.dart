// ignore_for_file: must_be_immutable, no_logic_in_create_state, constant_pattern_never_matches_value_type

import 'dart:async';

import 'package:convert/convert.dart';
import 'package:flutter/material.dart';

import 'package:cheetah_netdisk/components/card.dart';
import 'package:cheetah_netdisk/components/toast.dart';
import 'package:cheetah_netdisk/conf/const.dart';
import 'package:cheetah_netdisk/controller/file_controller.dart';

import 'package:get/get.dart';

import '../controller/share_controller.dart';
import '../models/file_model.dart';
import '../models/share_model.dart';

class ShareopContent extends StatefulWidget {
  ShareopContent({super.key, required this.share, required this.token, this.sc});
  ShareObj share;
  String token;
  ShareController? sc;

  @override
  State<ShareopContent> createState() => _SharePopContentState();
}

class _SharePopContentState extends State<ShareopContent> {
  _SharePopContentState();
  
  final expireOptions = ['永久有效', '7天有效', '15天有效', '30天有效'];
  final GlobalKey _formKey = GlobalKey<FormState>();
  String _code="", _expire="";
  int _cur = 0;

  Widget _getCodeBlank() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('提取码'),
        Container(
          width: 250,
          child: TextFormField(
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
                hintText: "请输入四位提取码",
                floatingLabelStyle: TextStyle(fontSize: 30),
                labelStyle: TextStyle(fontSize: 20)),
            validator: (value) {
              if (value == null || value.length > 4) {
                return '提取码无效';
              }
              return null;
            },
            onSaved: (v) {
              _code = v!;
            },
          ),
        )
      ],
    );
  }

  Widget _getExpireBlank() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('选择有效时间'),
        SizedBox(
          width: 250,
          child: MenuAnchor(
          menuChildren: [
            MenuItemButton(
              child: Text('7天有效'),
              onPressed: () {
                var time = DateTime.now().add(Duration(days: 7));
                _expire =
                    FixedDateTimeFormatter('YYYY-MM-DD hh:mm:ss', isUtc: false)
                        .encode(time);
                setState(() {
                  _cur = 1;
                });
              },
            ),
            MenuItemButton(
              child: Text('15天有效'),
              onPressed: () {
                var time = DateTime.now().add(Duration(days: 15));
                _expire =
                    FixedDateTimeFormatter('YYYY-MM-DD hh:mm:ss', isUtc: false)
                        .encode(time);
                setState(() {
                  _cur = 2;
                });
              },
            ),
            MenuItemButton(
              child: Text('30天有效'),
              onPressed: () {
                var time = DateTime.now().add(Duration(days: 30));
                _expire =
                    FixedDateTimeFormatter('YYYY-MM-DD hh:mm:ss', isUtc: false)
                        .encode(time);
                setState(() {
                  _cur = 3;
                });
              },
            ),
            MenuItemButton(
              child: Text('永久有效'),
              onPressed: () {
                _expire = '';
                setState(() {
                  _cur = 0;
                });
              },
            )
          ],
          builder:
              (BuildContext context, MenuController controller, Widget? child) {
            return TextButton(
              onPressed: () {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
              child: Text(expireOptions[_cur])
            );
          },
        ),)
      ],
    );
  }

  Widget _getCreateButton(BuildContext context) {
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
              Text('创建分享', style: Theme.of(context).primaryTextTheme.headline5),
          onPressed: () async{
            // 表单校验通过才会继续执行
            if ((_formKey.currentState as FormState).validate()) {
              (_formKey.currentState as FormState).save();
              widget.share.code = _code;
              widget.share.expireAt = _expire;
              widget.share.status = shareExpire;
              // 先退出，不然退出的是创建成功的弹窗
              Get.back();
              // 传入的share有uuid，代表更新
              await ShareController.createShare(widget.share, widget.token);
              if (widget.sc != null) {
                await widget.sc!.getAllShareData();
              }
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: CardWidget(
          height: 400,
          width: 300,
          content: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              _getCodeBlank(),
              SizedBox(
                height: 20,
              ),
              _getExpireBlank(),
              SizedBox(
                height: 20,
              ),
              Spacer(),
              _getCreateButton(context),
              SizedBox(
                height: 20,
              )
            ],
          ),
          color: Colors.white,
        ));
  }
}

class SharePop {
  showPop(ShareObj share, String token, {ShareController? sc}) {
    Get.bottomSheet(
      Container(
        height: 500,
        color: Colors.white,
        child: ShareopContent(
          share: share,
          token: token,
          sc: sc,
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
