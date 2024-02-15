import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walletium/utils/custom_color.dart';
import 'package:walletium/utils/dimsensions.dart';
import 'package:walletium/utils/size.dart';
import 'package:walletium/utils/strings.dart';
import 'package:walletium/widgets/buttons/primary_button_widget.dart';
import 'package:walletium/widgets/inputs/password_input_text_field.dart';
import 'package:walletium/widgets/labels/text_labels_widget.dart';
import 'package:walletium/widgets/others/back_button_widget.dart';

class ChangePasswordScreen extends StatefulWidget {
  ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  String fullName = '';
  String phone = '';
  String userId = '';

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      fullName = prefs.getString('fullName') ?? 'No name';
      phone = prefs.getString('phone') ?? 'No phone';
      userId = prefs.getString('userId') ?? '';
    });

    // Use the retrieved data wherever needed in the app
    print('Full Name: $fullName');
    print('Phone: $phone');
  }

  Future<void> changePassword() async {
    final String oldPassword = oldPasswordController.text;
    final String newPassword = newPasswordController.text;
    final String confirmPassword = confirmPasswordController.text;

    // Your server API URL to change password

    var response = await http.post(
      Uri.parse(Strings.apiURL + 'change_password.php'),
      body: {
        'userId': userId,
        'oldPassword': oldPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success']) {
        // Password changed successfully
        // Do something, e.g., show a snackbar or navigate to another screen
      } else {
        // Handle errors, show snackbar or other notifications
      }
    } else {
      // Show error snackbar
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          Strings.changePassword,
          style: TextStyle(color: CustomColor.textColor),
        ),
        leading: const BackButtonWidget(
          backButtonImage: Strings.backButtonWhite,
        ),
        backgroundColor: CustomColor.whiteColor,
        elevation: 0,
      ),
      body: _bodyWidget(context),
    );
  }

  ListView _bodyWidget(BuildContext context) {
    return ListView(
      children: [
        _inputWidgets(context),
        _changePasswordButtonWidget(context),
      ],
    );
  }

  Form _inputWidgets(BuildContext context) {
    return Form(
      child: Column(
        children: [
          addVerticalSpace(20.h),
          TextLabelsWidget(
            textLabels: Strings.oldPassword,
            textColor: CustomColor.textColor,
          ),
          Container(
            margin:
                EdgeInsets.symmetric(horizontal: Dimensions.marginSize * 0.5),
            child: PasswordInputTextField(
              controller: oldPasswordController,
              hintText: Strings.oldPassword,
            ),
          ),
          TextLabelsWidget(
            textLabels: Strings.newPassword,
            textColor: CustomColor.textColor,
          ),
          Container(
            margin:
                EdgeInsets.symmetric(horizontal: Dimensions.marginSize * 0.5),
            child: PasswordInputTextField(
              controller: newPasswordController,
              hintText: Strings.newPassword,
            ),
          ),
          TextLabelsWidget(
            textLabels: Strings.confirmPassword,
            textColor: CustomColor.textColor,
          ),
          Container(
            margin:
                EdgeInsets.symmetric(horizontal: Dimensions.marginSize * 0.5),
            child: PasswordInputTextField(
              controller: confirmPasswordController,
              hintText: Strings.confirmPassword,
            ),
          )
        ],
      ),
    );
  }

  PrimaryButtonWidget _changePasswordButtonWidget(BuildContext context) {
    return PrimaryButtonWidget(
      title: 'MODIFIER',
      onPressed: changePassword,
      borderColor: CustomColor.primaryColor,
      backgroundColor: CustomColor.primaryColor,
      textColor: CustomColor.whiteColor,
    );
  }
}
