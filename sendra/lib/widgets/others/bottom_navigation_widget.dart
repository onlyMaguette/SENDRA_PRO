import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:walletium/controller/bottom_navigation_controller.dart';
import 'package:walletium/utils/custom_color.dart';
import 'package:walletium/views/screens/carto.dart';
import 'package:walletium/views/screens/home_screen.dart';

class BottomNavigationWidget extends StatefulWidget {
  BottomNavigationWidget({Key? key}) : super(key: key);

  @override
  _BottomNavigationWidgetState createState() => _BottomNavigationWidgetState();
}

class _BottomNavigationWidgetState extends State<BottomNavigationWidget> {
  final _controller = Get.put(BottomNavigationController());

  static List<StatefulWidget> mainScreens = [
    const HomeScreen(),
    //const WalletScreen(),
    //const NotificationScreen(),
    //const ProfileScreen(),
    const CartoScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => Scaffold(
        backgroundColor: CustomColor.primaryBackgroundColor,
        body: mainScreens[_controller.getIndex()],
      ),
    );
  }

}
