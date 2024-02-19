import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walletium/controller/sign_in_controller.dart';
import 'package:walletium/routes/routes.dart';
import 'package:walletium/utils/custom_color.dart';
import 'package:walletium/utils/custom_style.dart';
import 'package:walletium/utils/dimsensions.dart';
import 'package:walletium/utils/size.dart';
import 'package:walletium/utils/strings.dart';
import 'package:walletium/widgets/buttons/primary_button_widget.dart';
import 'package:walletium/widgets/inputs/input_text_field.dart';
import 'package:walletium/widgets/labels/text_labels_widget.dart';
import 'package:walletium/widgets/others/back_button_widget.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  //SignInScreen({Key? key}) : super(key: key);
  final _controller = Get.put(SignInController());
  final formKey = GlobalKey<FormState>();
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _bodyWidget(context),
    );
  }

// Method to save user data in SharedPreferences after sign-in
  Future<void> saveUserData(String fullName, String phone, userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('fullName', fullName);
    await prefs.setString('phone', phone);
    await prefs.setString('userId', userId);
  }

  Future<void> _signIn() async {
    // Get the user input
    String telephone = _controller.emailOrUserNameController.text;
    String password = _controller.passwordController.text;

    try {
      // Send an HTTP POST request to the API endpoint
      // Create a map of the request body
      Map<String, String> requestBody = {
        'telephone': '+221' + telephone,
        'password': password,
      };

      // Send an HTTP POST request to the API endpoint
      final response = await http.post(
        Uri.parse(Strings.apiURL + 'connexion.php'),
        body: requestBody,
      );

      // Process the API response
      if (response.statusCode == 200) {
        // Successful authentication
        // You can navigate to the next screen here
        //Navigator.pushNamed(context, '/home');
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        print(jsonResponse);
        if (jsonResponse['success'] == true) {
          // Successful authentication, do something (e.g., navigate to the home screen).
          bool success = jsonResponse['success'];
          String fullName = jsonResponse['fullName'];
          String userId = jsonResponse['userId'].toString();

          // After successful sign-in, save user data in SharedPreferences
          await saveUserData(fullName, telephone, userId);
          // Use the data as needed...
          print('API Response: $jsonResponse');
          print('Success: $success');
          Get.toNamed(Routes.bottomNavigationScreen);
        } else {
          // Authentication failed, show an error message.
          print(
              'Authentication failed!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red,
                    ),
                    SizedBox(width: 8),
                    Text('Erreur'),
                  ],
                ),
                content: Text(
                    'La connexion a échoué. Vérifiez le login et le mot de passe.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } else {
        // Authentication failed
        // Update the error message
        setState(() {
          _errorMessage = 'Authentication failed';
        });
      }
    } catch (error) {
      // Error occurred during the HTTP request
      setState(() {
        _errorMessage = 'An error occurred during the request: $error';
      });
    }
  }

  ScrollConfiguration _bodyWidget(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
        },
      ),
      child: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Strings.signInBg),
            fit: BoxFit.fill,
          ),
        ),
        child: ListView(
          physics: BouncingScrollPhysics(),
          children: [
            _backButton(context),
            _titleAndDesWidget(context),
            addVerticalSpace(100.h),
            _inputWidgets(context),
            _signInButtonWidget(context),
            _forgotPasswordWidget(context),
            _signUpWidget(context),
          ],
        ),
      ),
    );
  }

  Container _backButton(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      margin: EdgeInsets.all(Dimensions.marginSize * 0.5),
      child: Row(
        children: [
          const BackButtonWidget(
            backButtonImage: Strings.backButton,
          ),
          addHorizontalSpace(10.w),
          Text(
            Strings.signIn,
            style: CustomStyler.signInStyle,
          )
        ],
      ),
    );
  }

  Container _titleAndDesWidget(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(Dimensions.marginSize),
      child: Column(
        crossAxisAlignment: crossStart,
        children: [
          Text(
            Strings.signInTitle,
            style: CustomStyler.signInTitleStyle,
          ),
          addVerticalSpace(10.h),
          Text(
            Strings.signInDescription,
            style: CustomStyler.onboardDesStyle,
          ),
        ],
      ),
    );
  }

  Form _inputWidgets(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextLabelsWidget(
            textLabels: Strings.emailOrUsername,
            textColor: CustomColor.whiteColor,
          ),
          Container(
            margin:
                EdgeInsets.symmetric(horizontal: Dimensions.marginSize * 0.5),
            child: TextFormField(
              controller: _controller.emailOrUserNameController,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Veuillez saisir le nom';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: Strings.emailOrUsername,
                hintStyle: TextStyle(color: CustomColor.gray),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: CustomColor.gray),
                ),
              ),
            ),
          ),
          TextLabelsWidget(
            textLabels: Strings.password,
            textColor: CustomColor.whiteColor,
          ),
          Container(
            margin:
                EdgeInsets.symmetric(horizontal: Dimensions.marginSize * 0.5),
            child: TextFormField(
              controller: _controller.passwordController,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Veuillez saisir le mot de passe';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: Strings.password,
                hintStyle: TextStyle(color: CustomColor.gray),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: CustomColor.gray),
                ),
              ),
              obscureText: true,
            ),
          )
        ],
      ),
    );
  }

  Column _signInButtonWidget(BuildContext context) {
    return Column(children: [
      PrimaryButtonWidget(
        title: Strings.signIn,
        onPressed: () {
          //Get.toNamed(Routes.bottomNavigationScreen);
          if (formKey.currentState != null &&
              formKey.currentState!.validate()) {
            _signIn();
          }
        },
        borderColor: Color.fromARGB(255, 27, 27, 55),
        backgroundColor: CustomColor.textColor,
        textColor: CustomColor.whiteColor,
      ),
      Text(
        _errorMessage,
        style: TextStyle(color: Colors.white),
      ),
    ]);
  }

  Container _forgotPasswordWidget(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.all(Dimensions.marginSize),
      child: GestureDetector(
        onTap: () {
          _forgotPasswordScreen(context);
        },
        child: const Text(
          Strings.forgotPassword,
          style: TextStyle(color: CustomColor.whiteColor),
        ),
      ),
    );
  }

  Container _signUpWidget(BuildContext context) {
    return Container(
        alignment: Alignment.bottomCenter,
        margin: EdgeInsets.all(Dimensions.marginSize),
        child: Row(
          mainAxisAlignment: mainCenter,
          children: [
            const Text(
              Strings.newToRemesa,
              style: TextStyle(
                color: CustomColor.whiteColor,
              ),
            ),
            GestureDetector(
              onTap: () {
                Get.toNamed(Routes.signUpScreen);
              },
              child: const Text(
                Strings.signUp,
                style: TextStyle(
                    color: CustomColor.whiteColor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ));
  }

  //Forgot Password Screen
  Future _forgotPasswordScreen(BuildContext context) {
    final forgotFormKey = GlobalKey<FormState>();
    var width = MediaQuery.of(context).size.width;
    return showDialog(
        context: context,
        builder: (_) => AlertDialog(
            backgroundColor: CustomColor.whiteColor,
            alignment: Alignment.center,
            insetPadding: EdgeInsets.all(Dimensions.defaultPaddingSize * 0.2),
            contentPadding: EdgeInsets.zero,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Builder(
              builder: (context) {
                return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: CustomColor.primaryBackgroundColor,
                    ),
                    padding: const EdgeInsets.all(10),
                    width: width * 0.9,
                    height: 500,
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            addVerticalSpace(20.h),
                            Container(
                              decoration: const BoxDecoration(
                                color: CustomColor.primaryBackgroundColor,
                              ),
                              child: Image.asset(
                                Strings.forgotPassImage,
                                height: 100,
                              ),
                            ),
                            addVerticalSpace(20.h),
                            Text(
                              Strings.forgotPasswordTitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: CustomColor.textColor,
                                  fontSize: Dimensions.largeTextSize + 5,
                                  fontWeight: FontWeight.w700),
                            ),
                            addVerticalSpace(20.h),
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: Dimensions.marginSize),
                              width: double.infinity,
                              child: Text(
                                Strings.forgotPasswordDescription,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: CustomColor.textColor.withOpacity(0.6),
                                ),
                              ),
                            ),
                            TextLabelsWidget(
                              margin: 0.5,
                              textLabels: Strings.phoneNumber,
                              textColor: CustomColor.textColor,
                            ),
                            Form(
                              key: forgotFormKey,
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: Dimensions.marginSize * 0.5),
                                child: InputTextField(
                                  hintText: Strings.enterPhoneNumber,
                                  hintTextColor: CustomColor.textColor,
                                  backgroundColor: CustomColor.whiteColor,
                                  controller: _controller.emailController,
                                  borderColor: CustomColor.gray,
                                ),
                              ),
                            ),
                            PrimaryButtonWidget(
                              title: Strings.conTinue,
                              onPressed: () {
                                Get.toNamed(Routes.otpVerificationScreen);
                              },
                              textColor: CustomColor.whiteColor,
                              backgroundColor: CustomColor.textColor,
                              borderColor: CustomColor.textColor,
                            ),
                          ],
                        ),
                        Positioned(
                            top: 5,
                            right: 5,
                            child: IconButton(
                              onPressed: () {
                                Get.back();
                              },
                              icon: const Icon(
                                Icons.close,
                                color: CustomColor.gray,
                              ),
                            ))
                      ],
                    ));
              },
            )));
  }
}
