import 'package:flutter/material.dart';

class NoDataPage extends StatelessWidget {
  const NoDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: FractionalOffset(0.5, 0.8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
        Image.asset('assets/images/nodata.png', width: 120, height: 120,),
        SizedBox(height: 20,),
        Text(
          "什么也没有啊",
          style: const TextStyle(fontSize: 20),
        ),
      ]),
    );
  }
}