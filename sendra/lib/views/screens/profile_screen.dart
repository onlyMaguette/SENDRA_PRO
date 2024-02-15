import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walletium/routes/routes.dart';
import 'package:walletium/utils/custom_color.dart';
import 'package:walletium/utils/custom_style.dart';
import 'package:walletium/utils/dimsensions.dart';
import 'package:walletium/utils/size.dart';
import 'package:walletium/utils/strings.dart';
import 'package:walletium/views/screens/drawer_screen.dart';

import '../../widgets/others/back_button_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String fullName = '';
  String phone = '';

  @override
  void initState() {
    super.initState();
    // Fetch the user data when the widget is initialized
    getUserData();
  }

  Future<void> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      fullName = prefs.getString('fullName') ?? 'No name';
      phone = prefs.getString('phone') ?? 'No phone';
    });
    // Use the retrieved data wherever needed in the app
    print('Full Name: $fullName');
    print('Phone: $phone');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.primaryBackgroundColor,
      drawer: const DrawerScreen(),
      appBar: AppBar(
        backgroundColor: CustomColor.primaryColor,
        iconTheme: const IconThemeData(color: CustomColor.whiteColor),
        title: const Text(Strings.profile),
        elevation: 0,
        leading: const BackButtonWidget(
          backButtonImage: Strings.backButtonWhite,
        ),
      ),
      body: _bodyWidget(context),
    );
  }

  ListView _bodyWidget(BuildContext context) {
    return ListView(
      children: [
        //_profilePicture(context),
        addVerticalSpace(10.h),
        _usernameAndUserId(context),
        addVerticalSpace(20.h),
        _containerWidget(context),
      ],
    );
  }

  Container _profilePicture(BuildContext context) {
    return Container(
      width: 150.h,
      height: 150.h,
      margin: EdgeInsets.symmetric(vertical: Dimensions.marginSize * 0.5),
      decoration: const BoxDecoration(
        color: CustomColor.textColor,
        image: DecorationImage(
            image: AssetImage(Strings.notificationImage),
            fit: BoxFit.fitHeight),
        shape: BoxShape.circle,
      ),
    );
  }

  Column _usernameAndUserId(BuildContext context) {
    return Column(
      mainAxisAlignment: mainCenter,
      crossAxisAlignment: crossCenter,
      children: [
        Text(
          fullName,
          style: CustomStyler.profileNameStyle,
        ),
        /*Row(
          mainAxisAlignment: mainCenter,
          children: [
            Text(
              Strings.userId,
              style: CustomStyler.userIdStyle,
            ),
            Text(Strings.userIdNUmber, style: CustomStyler.userIdStyle),
          ],
        )*/
      ],
    );
  }

  Column _containerWidget(BuildContext context) {
    return Column(
      children: [
        /*_smallContainer(
            context, Icons.account_circle_rounded, Strings.editProfile, () {
          Get.toNamed(Routes.editProfileScreen);
        }),
        addVerticalSpace(10.h),*/

        _smallContainer(context, Icons.key, Strings.changePassword, () {
          Get.toNamed(Routes.changePasswordScreen);
        }),
      ],
    );
  }

  InkWell _smallContainer(BuildContext context, IconData icon, String name,
      VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: Dimensions.marginSize * 0.5),
        padding: EdgeInsets.all(Dimensions.defaultPaddingSize * 0.3),
        decoration: BoxDecoration(
          color: CustomColor.whiteColor,
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Row(
          mainAxisAlignment: mainSpaceBet,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: CustomColor.textColor,
                  size: 30,
                ),
                addHorizontalSpace(5.w),
                Text(
                  name,
                  style: CustomStyler.editProfileStyle,
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios_sharp,
              color: CustomColor.textColor,
            ),
          ],
        ),
      ),
    );
  }
}
