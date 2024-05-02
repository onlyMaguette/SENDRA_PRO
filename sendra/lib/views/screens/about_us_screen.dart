import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:walletium/utils/custom_color.dart';
import 'package:walletium/utils/custom_style.dart';
import 'package:walletium/utils/dimsensions.dart';
import 'package:walletium/utils/size.dart';
import 'package:walletium/utils/strings.dart';
import 'package:walletium/widgets/others/back_button_widget.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          Strings.aboutUs,
          style: TextStyle(color: CustomColor.whiteColor),
        ),
        leading: const BackButtonWidget(
          backButtonImage: Strings.backButtonWhite,
        ),
        backgroundColor: CustomColor.primaryColor,
        elevation: 0,
      ),
      body: _bodyWidget(context),
    );
  }

  ListView _bodyWidget(BuildContext context) {
    return ListView(
      children: [
        addVerticalSpace(20.h),
        _imageWidget(context),
        addVerticalSpace(20.h),
        _aboutUsDescription(context),
        _copyRightWidget(context)
      ],
    );
  }

  Container _imageWidget(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Image.asset(
        'assets/images/EPAVIE2.png',
        fit: BoxFit.contain,
      ),
    );
  }

  Container _aboutUsDescription(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(Dimensions.marginSize * 0.5),
      child: Column(
        children: [
          /*Text(
            Strings.aboutUsPartOne,
            textAlign: TextAlign.justify,
            style: CustomStyler.aboutUsDesStyle,
          ),
          addVerticalSpace(20.h),
          Text(
            Strings.aboutUsPartTwo,
            textAlign: TextAlign.justify,
            style: CustomStyler.aboutUsDesStyle,
          ),
          addVerticalSpace(20.h),
          Text(
            Strings.aboutUsPartThree,
            textAlign: TextAlign.justify,
            style: CustomStyler.aboutUsDesStyle,
          ),
          addVerticalSpace(20.h),
          Text(
            Strings.aboutUsPartFour,
            textAlign: TextAlign.justify,
            style: CustomStyler.aboutUsDesStyle,
          ),*/
        ],
      ),
    );
  }

  Container _copyRightWidget(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            Text(
              Strings.copyright,
              style: CustomStyler.copyrightStyle,
            ),
            Text(
              Strings.websiteLink,
              style: CustomStyler.websiteStyle,
            ),
          ],
        ));
  }
}
