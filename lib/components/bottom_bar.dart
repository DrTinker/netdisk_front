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
    var _list = List.generate(5, (i) {
      if (i != 2) {
        return BottomNavigationBarItem(
          icon: tabImages[i][0],
          activeIcon: tabImages[i][1],
          label: tabLabels[i],
        );
      } else {
        return const BottomNavigationBarItem(
          icon: SizedBox(),
        );
      }
    });

    return BottomNavigationBar(
        currentIndex: index,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => {Get.offNamed(tabRouters[index])},
        items: [
          _list[0],
          _list[1],
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/share.png',
              height: 0,
              width: 0,
            ),
            label: '',
          ),
          _list[3],
          _list[4],
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return _getBottomBar();
  }
}
