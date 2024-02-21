import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:walletium/controller/deposit_controller.dart';
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

import '../../widgets/others/input_picture_widget.dart';

class DepositScreen extends StatefulWidget {
  DepositScreen({Key? key}) : super(key: key);

  @override
  _DepositScreenState createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final _controller = Get.put(DepositController());
  File? _selectedImage;
  //LocationData? locationData;
  Position? locationData;
  String? commune;
  String? quartier;

  String locality = '';
  String subLocality = '';

  double? latitude;
  double? longitude;

  bool _isLoading = false; // Added variable to track loading state

  Future<void> getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        locationData = null;
      });
      return;
    }

    // Request location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        setState(() {
          locationData = null;
        });
        return;
      }
    }

    // Get current location
    Position currentPosition = await Geolocator.getCurrentPosition();
    latitude = currentPosition.latitude;
    longitude = currentPosition.longitude;
    setState(() {
      locationData = currentPosition;
    });

    if (locationData != null) {
      // Get address from coordinates
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          locationData!.latitude,
          locationData!.longitude,
        );

        if (placemarks.isNotEmpty) {
          setState(() {
            locality = placemarks.first.locality ?? '';
            subLocality = placemarks.first.subLocality ?? '';
            if (subLocality.isEmpty) {
            } else {
              locality = subLocality;
            }
          });
        }
      } catch (e) {
        print(e);
      }
    }
  }

  Future<void> _submitImage() async {
    if (_controller.carImagePath.value == null) {
      return;
    }

// Set loading state to true before fetching location
    setState(() {
      _isLoading = true;
    });

    var request = http.MultipartRequest(
      'POST',
      Uri.parse(Strings.apiURL + 'signalement.php'),
    );

    // Add the string variable as a field
    request.fields['titre'] = _controller.titreController.text;

    // Call getUserLocation() function asynchronously
    await getLocation();

    request.fields['commune'] = '$locality';
    request.fields['quartier'] = '$subLocality';
    request.fields['latitude'] = '$latitude';
    request.fields['longitude'] = '$longitude';
    request.fields['telephone'] = '774208140';

    // Convert image to base64
    String base64String =
        base64Encode(File(_controller.carImagePath.value).readAsBytesSync());
    request.fields['image'] = base64String;

    /*request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        _controller.carImagePath.value,
      ),
    );*/

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        setState(() {
          _isLoading = false;
          // Reset values after saving data
          _controller.titreController.text = ''; // Reset the title field
        });
        // Image upload successful
        // Process the response as needed
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirmation'),
              content: Text('Bravo! Votre signalement a été pris en compte.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    //Get.toNamed(Routes.depositMoneyDetailsScreen);
                    Get.toNamed(Routes.bottomNavigationScreen);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
        //Get.toNamed(Routes.depositMoneyDetailsScreen);
      } else {
        // Image upload failed
        // Handle the error
      }
    } catch (e) {
      // Error occurred during the request
      // Handle the error
      showErrorMessage('Une erreur s’est produite: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          Strings.signalement,
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
        _inputWidget(context),
        addVerticalSpace(20.h),
        // _detailsWidget(context),
        _carPicture(context),
        _continueButtonWidget(context),
      ],
    );
  }

  Form _inputWidget(BuildContext context) {
    return Form(
      key: _controller.formKey,
      child: Column(
        children: [
          addVerticalSpace(40.h),
          TextLabelsWidget(
            textLabels: Strings.titre,
            textColor: CustomColor.textColor,
          ),
          Container(
            margin:
                EdgeInsets.symmetric(horizontal: Dimensions.marginSize * 0.5),
            child: InputTextField(
                borderColor: CustomColor.textColor,
                //labelTextName: Strings.amount,
                controller: _controller.titreController,
                hintText: Strings.titre,
                backgroundColor: CustomColor.whiteColor,
                hintTextColor: CustomColor.textColor),
          ),
          addVerticalSpace(20.h),
          /*TextLabelsWidget(
            textLabels: Strings.paymentMethod,
            textColor: CustomColor.textColor,
          ),*/
          /*Container(
              margin:
                  EdgeInsets.symmetric(horizontal: Dimensions.marginSize * 0.5),
              child: const PaymentMethodInputTextFieldWidget()),*/
        ],
      ),
    );
  }

  Container _detailsWidget(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(Dimensions.marginSize * 0.5),
      child: Column(
        mainAxisAlignment: mainStart,
        crossAxisAlignment: crossStart,
        children: [
          _rowWidget(context, Strings.feesJust, Strings.feesMoney),
          const Divider(),
          _rowWidget(context, Strings.total, Strings.totalDepositMoney),
        ],
      ),
    );
  }

  PrimaryButtonWidget _continueButtonWidget(BuildContext context) {
    return PrimaryButtonWidget(
      title: Strings.valider,
      onPressed: () {
        _submitImage();
        //Get.toNamed(Routes.depositMoneyDetailsScreen);
      },
      borderColor: CustomColor.primaryColor,
      backgroundColor: CustomColor.primaryColor,
      textColor: CustomColor.whiteColor,
      isLoading: _isLoading, // Pass _isLoading to isLoading parameter
    );
  }

  Row _rowWidget(BuildContext context, String title, String amount) {
    return Row(
      mainAxisAlignment: mainSpaceBet,
      children: [
        Text(
          title,
          style: CustomStyler.otpVerificationDescriptionStyle,
        ),
        Row(
          children: [
            Text(
              amount,
              style: CustomStyler.otpVerificationDescriptionStyle,
            ),
            addHorizontalSpace(5.w),
            Text(
              Strings.usd,
              style: CustomStyler.otpVerificationDescriptionStyle,
            ),
          ],
        )
      ],
    );
  }

  InputImageWidget _carPicture(BuildContext context) {
    return InputImageWidget();
  }

  void showErrorMessage(String message) {
    final snackBar = SnackBar(
      content: Text(message),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
