import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<Widget> deviceInfoHelper() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  return Column(
    children: [
      ListTile(
        leading: Text('制造商: '),
        title: Text(androidInfo.manufacturer),
      ),
      ListTile(
        leading: Text('设备名称: '),
        title: Text(androidInfo.model),
      ),
      ListTile(
        leading: Text('操作系统: '),
        title: Text('Android ${androidInfo.version.release}'),
      ),
    ],
  );
}
