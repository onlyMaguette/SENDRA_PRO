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
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          color: CustomColor.primaryBackgroundColor,
          clipBehavior: Clip.hardEdge,
          notchMargin: 6,
          height: kBottomNavigationBarHeight + 50,

          child: BottomNavigationBar(
            onTap: (index) => _controller.setIndex(index),
            backgroundColor: CustomColor.primaryColor,
            currentIndex: _controller.getIndex(),
            selectedItemColor: CustomColor.whiteColor,
            unselectedItemColor: CustomColor.whiteColor.withOpacity(0.5),
            type: BottomNavigationBarType.fixed,
            unselectedFontSize: 11,
            selectedFontSize: 12,
            elevation: 12,
            selectedIconTheme: IconThemeData(
              color: Colors.white,
            ),
            selectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            items: BottomNavigationController.navigationBarItems.map((item) {
              return BottomNavigationBarItem(
                icon: Expanded(
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30), // Bordure arrondie
                      border: Border.all(
                        color: CustomColor.primaryColor, // Couleur de la bordure
                        width: 2, // Largeur de la bordure
                      ),
                    ),
                    child: item.icon,
                  ),
                ),
                label: item.label,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

}
