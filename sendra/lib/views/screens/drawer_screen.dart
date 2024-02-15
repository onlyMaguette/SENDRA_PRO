import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
          _drawerList(context),
        ],
      ),
    );
  }

  Container _headerDrawer(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.25,
      padding: EdgeInsets.all(Dimensions.defaultPaddingSize),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9F9),
      ),
      child: Column(
        mainAxisAlignment: mainEnd,
        crossAxisAlignment: crossCenter,
        children: [
          Image.asset(Strings.splashLogo),
        ],
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
          25,
          () {
            Get.toNamed(Routes.transactionsHistoryScreen);
          },
        ),
        /* _menuItems(
          context,
          Strings.transferHistory,
          FontAwesomeIcons.solidPaperPlane,
          25,
          () {
            Get.toNamed(Routes.transferHistoryScreen);
          },
        ),*/
        /* _menuItems(
          context,
          Strings.depositHistory,
          FontAwesomeIcons.solidMoneyBill1,
          25,
              () {
            Get.toNamed(Routes.depositHistoryScreen);
          },
        ),*/
        /*_menuItems(
          context,
          Strings.withdrawHistory,
          FontAwesomeIcons.arrowUpFromBracket,
          25,
              () {
            Get.toNamed(Routes.withdrawHistoryScreen);
          },
        ),*/
        /*_menuItems(
          context,
          Strings.kyc,
          FontAwesomeIcons.idCard,
          25,
          () {
            Get.toNamed(Routes.kycScreen);
          },
        ),*/
        _menuItems(
          context,
          Strings.aboutUs,
          FontAwesomeIcons.circleInfo,
          25,
          () {
            Get.toNamed(Routes.aboutUsScreen);
          },
        ),
        /*_menuItems(
          context,
          Strings.privacyPolicy,
          FontAwesomeIcons.headphones,
          25,
          () {},
        ),
        _menuItems(
          context,
          Strings.shareApp,
          Icons.share,
          25,
          () {},
        ),*/
        _menuItems(
          context,
          Strings.profile,
          Icons.person,
          25,
          () {
            Get.toNamed(Routes.profileScreen);
          },
        ),
        _menuItems(
          context,
          Strings.signOut,
          Icons.power_settings_new,
          25,
          () {
            Get.toNamed(Routes.signInScreen);
          },
        ),
        addVerticalSpace(50.h),
      ],
    );
  }

  InkWell _menuItems(BuildContext context, String screenName, IconData icon,
      double iconSize, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      splashColor: CustomColor.primaryColor,
      child: Padding(
        padding:
            EdgeInsets.symmetric(vertical: Dimensions.defaultPaddingSize * 0.4),
        child: Row(
          children: [
            Expanded(
              child: Icon(
                icon,
                size: iconSize,
                color: CustomColor.textColor,
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                screenName,
                style: const TextStyle(
                    color: CustomColor.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w100),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
