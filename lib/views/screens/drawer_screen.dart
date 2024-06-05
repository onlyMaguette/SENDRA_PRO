import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:walletium/routes/routes.dart';
import 'package:walletium/utils/custom_color.dart';
import 'package:walletium/utils/dimsensions.dart';
import 'package:walletium/utils/size.dart';
import 'package:walletium/utils/strings.dart';

class DrawerScreen extends StatelessWidget {
  const DrawerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: CustomColor.whiteColor,
      child: ListView(
        children: [
          _headerDrawer(context),
          SizedBox(height: 20),
          _drawerList(context),
        ],
      ),
    );
  }

  Container _headerDrawer(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.2,
      padding: EdgeInsets.all(Dimensions.defaultPaddingSize),
      decoration: BoxDecoration(
        color: Color(0xFFF8F9F9),
      ),
      child: Image.asset(
        'assets/images/EPAVIE2.png',
        fit: BoxFit.cover,
      ),
    );
  }

  Column _drawerList(BuildContext context) {
    return Column(
      children: [
        _menuItems(
          context,
          Strings.transactionHistory,
          Icons.insert_drive_file,
              () {
            Get.toNamed(Routes.transactionsHistoryScreen);
          },
        ),
        _menuItems(
          context,
          Strings.aboutUs,
          FontAwesomeIcons.infoCircle,
              () {
            Get.toNamed(Routes.aboutUsScreen);
          },
        ),
        _menuItems(
          context,
          Strings.profile,
          Icons.person,
              () {
            Get.toNamed(Routes.profileScreen);
          },
        ),
        Divider(color: CustomColor.textColor), // Séparateur personnalisé
        _menuItems(
          context,
          Strings.signOut,
          Icons.power_settings_new,
              () {
            Get.toNamed(Routes.signInScreen);
          },
        ),
        SizedBox(height: 20),
      ],
    );
  }

  ListTile _menuItems(BuildContext context, String screenName, IconData icon,
      VoidCallback onPressed) {
    return ListTile(
      onTap: onPressed,
      leading: Icon(
        icon,
        color: CustomColor.primaryColor,
      ),
      title: Text(
        screenName,
        style: TextStyle(
          color: CustomColor.textColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
