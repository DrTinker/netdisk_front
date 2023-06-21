// ignore_for_file: no_logic_in_create_state

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../conf/navi.dart';

class BottomBar extends StatefulWidget {
  BottomBar({super.key, required this.index});
  int index;
  @override
  State<BottomBar> createState() => _BottomBarState(index: index);
}

class _BottomBarState extends State<BottomBar> {
  _BottomBarState({required this.index});
  int index;
  Widget _getBottomBar() {
      var _list = List.generate(4, (i) {
        return BottomNavigationBarItem(
          icon: tabImages[i][0],
          activeIcon: tabImages[i][1],
          label: tabLabels[i],
        );
      });

      return BottomNavigationBar(
          currentIndex: index,
          type: BottomNavigationBarType.fixed,
          onTap: (index) => {Get.toNamed(tabRouters[index])},
          items: [
            _list[0],
            _list[1],
            BottomNavigationBarItem(
              icon: Image.asset('assets/icons/share.png', height: 0, width: 0,),
              label: '',
            ),
            _list[2],
            _list[3],
          ]
        );
    }
  @override
  Widget build(BuildContext context) {
    return _getBottomBar();
  }
}