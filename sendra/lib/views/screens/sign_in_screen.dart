import 'dart:convert';

import 'dart:io'; // Ajoutez cette ligne pour importer SocketException
import 'dart:async'; // Ajoutez cette ligne pour importer TimeoutException
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
  final _controller = Get.put(SignInController());
  final formKey = GlobalKey<FormState>();
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _bodyWidget(context),
    );
  }

  Future<void> saveUserData(String fullName, String phone, id, token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('fullName', fullName);
    await prefs.setString('phone', phone);
    await prefs.setString('userId', id);
    await prefs.setString('token', token);
  }

  Future<void> _signIn() async {
    String telephone = _controller.emailOrUserNameController.text;
    String password = _controller.passwordController.text;

    if (telephone.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez saisir le numéro de téléphone et le mot de passe.';
      });
      return;
    }

    try {
      Map<String, String> requestBody = {
        'telephone': telephone,
        'password': password,
      };

      final response = await http.post(
        Uri.parse(Strings.apiURI + 'login'),
        body: requestBody,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        bool success = jsonResponse['success'];
        if (success) {
          String fullName = jsonResponse['fullName'].toString();
          String userId = jsonResponse['userId'].toString();
          String token = jsonResponse['token'].toString();

          await saveUserData(fullName, telephone, userId, token);

          Get.toNamed(Routes.bottomNavigationScreen);
        } else {
          String errorMessage = jsonResponse['error'].toString();
          setState(() {
            _errorMessage = errorMessage;
          });
        }
      } else if (response.statusCode == 401) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Erreur de connexion',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Les informations saisies sont incorrectes. Veuillez vérifier le numéro de téléphone et le mot de passe.',
                    style: TextStyle(
                      color: CustomColor.textColor,
                    ),
                  ),
                ],
              ),
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
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Erreur',
                style: TextStyle(
                  color: CustomColor.textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Une erreur s’est produite lors de la demande. Veuillez réessayer plus tard.',
                    style: TextStyle(
                      color: CustomColor.textColor,
                    ),
                  ),
                ],
              ),
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
    } catch (error) {
      String errorMessage;
      if (error is SocketException) {
        errorMessage = 'Erreur de connexion réseau. Veuillez vérifier votre connexion internet.';
      } else if (error is TimeoutException) {
        errorMessage = 'La demande a expiré. Veuillez réessayer plus tard.';
      } else {
        errorMessage = 'Une erreur s\'est produite : $error';
      }
      setState(() {
        _errorMessage = errorMessage;
      });
    }

  }

  Widget _bodyWidget(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Colors.green.shade900,
          ],
        ),
      ),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _backButton(context),
            _titleAndDesWidget(context),
            SizedBox(height: 20.h),
            _inputWidgets(context),
            SizedBox(height: 10.h),
            _signInButtonWidget(context),
            SizedBox(height: 5.h),
            _forgotPasswordWidget(context),
            SizedBox(height: 5.h),
            _signUpWidget(context),
          ],
        ),
      ),
    );
  }

  Widget _backButton(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      margin: EdgeInsets.all(Dimensions.marginSize * 0.5),
      child: Row(
        children: [
          BackButtonWidget(
            backButtonImage: Strings.backButton,
          ),
          SizedBox(width: 10.w),
          Text(
            Strings.signIn,
            style: TextStyle(
              color: CustomColor.textColor,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }

  Widget _titleAndDesWidget(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(Dimensions.marginSize),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/EPAVIE2.png',
            fit: BoxFit.contain,
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.width * 0.9 * (3 / 4),
          ),
        ],
      ),
    );
  }

  Widget _inputWidgets(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextLabelsWidget(
            textLabels: Strings.phoneNumber,
            textColor: CustomColor.whiteColor,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: Dimensions.marginSize * 0.5),
            child: TextFormField(
              controller: _controller.emailOrUserNameController,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Veuillez saisir votre numéro de téléphone';
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
            margin: EdgeInsets.symmetric(horizontal: Dimensions.marginSize * 0.5),
            child: TextFormField(
              controller: _controller.passwordController,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Veuillez saisir votre mot de passe';
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

  Widget _signInButtonWidget(BuildContext context) {
    return Column(
      children: [
        PrimaryButtonWidget(
          title: Strings.signIn,
          onPressed: () {
            if (formKey.currentState != null && formKey.currentState!.validate()) {
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
      ],
    );
  }

  Widget _forgotPasswordWidget(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(top: 5.h),
      child: GestureDetector(
        onTap: () {
          _forgotPasswordScreen(context);
        },
        child: Text(
          Strings.forgotPassword,
          style: TextStyle(
            color: CustomColor.whiteColor,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _signUpWidget(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      margin: EdgeInsets.all(Dimensions.marginSize),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            Strings.newToRemesa,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: CustomColor.whiteColor,
            ),
          ),
          GestureDetector(
            onTap: () {
              Get.toNamed(Routes.signUpScreen);
            },
            child: Text(
              Strings.signUp,
              style: TextStyle(
                color: CustomColor.whiteColor,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                            SizedBox(height: 20.h),
                            Container(
                              decoration: const BoxDecoration(
                                color: CustomColor.primaryBackgroundColor,
                              ),
                              child: Image.asset(
                                Strings.forgotPassImage,
                                height: 100,
                              ),
                            ),
                            SizedBox(height: 20.h),
                            Text(
                              Strings.forgotPasswordTitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: CustomColor.textColor,
                                  fontSize: Dimensions.largeTextSize + 5,
                                  fontWeight: FontWeight.w700),
                            ),
                            SizedBox(height: 20.h),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: Dimensions.marginSize),
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
                                margin: EdgeInsets.symmetric(horizontal: Dimensions.marginSize * 0.5),
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
                              icon: Icon(
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
