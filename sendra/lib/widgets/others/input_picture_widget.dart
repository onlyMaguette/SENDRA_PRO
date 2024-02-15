import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as Img; // Import the image package
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:walletium/controller/deposit_controller.dart';
import 'package:walletium/controller/input_image_controller.dart';
import 'package:walletium/utils/custom_color.dart';
import 'package:walletium/utils/dimsensions.dart';
import 'package:walletium/utils/size.dart';
import 'package:walletium/utils/strings.dart';

// ignore: must_be_immutable
class InputImageWidget extends StatelessWidget {
  InputImageWidget({Key? key}) : super(key: key);
  final _controller = Get.put(InputImageController());
  final _controller_deposit = Get.put(DepositController());

  File? pickedFile;

  ImagePicker imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
          width: 100.w,
          height: 150.h,
          margin: EdgeInsets.all(Dimensions.marginSize * 0.5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: CustomColor.inputBackgroundColor,
            image: DecorationImage(
              image: _controller.carImagePath.value.isNotEmpty
                  ? FileImage(File(_controller.carImagePath.value))
                      as ImageProvider
                  : const AssetImage(Strings.carPlaceHolder),
              // fit: BoxFit.cover,
            ),
          ),
          child: Container(
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.all(Dimensions.defaultPaddingSize * 0.3),
            child: InkWell(
              onTap: () {
                showModalBottomSheet(
                    context: context,
                    builder: (context) => _bottomSheet(context));
              },
              child: const Icon(
                Icons.camera_alt,
                color: CustomColor.whiteColor,
              ),
            ),
          )),
    );
  }

  Container _bottomSheet(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100.h,
      margin: EdgeInsets.all(Dimensions.marginSize * 0.5),
      // decoration: const BoxDecoration(
      //     color: Colors.orange,
      //     shape: BoxShape.circle
      // ),
      child: Row(
        mainAxisAlignment: mainCenter,
        children: [
          Padding(
            padding: EdgeInsets.all(Dimensions.defaultPaddingSize),
            child: IconButton(
                onPressed: () {
                  takeCarPhoto(ImageSource.gallery);
                },
                icon: const Icon(
                  Icons.image,
                  color: Color.fromARGB(255, 31, 67, 43),
                  size: 50,
                )),
          ),
          Padding(
            padding: EdgeInsets.all(Dimensions.defaultPaddingSize),
            child: IconButton(
                onPressed: () {
                  takeCarPhoto(ImageSource.camera);
                },
                icon: const Icon(
                  Icons.camera,
                  color: CustomColor.primaryColor,
                  size: 50,
                )),
          ),
        ],
      ),
    );
  }

  Future<void> takePhoto(ImageSource source) async {
    final pickedImage =
        await imagePicker.pickImage(source: source, imageQuality: 100);
    if (pickedFile != null) {
      pickedFile = File(pickedImage!.path);
      _controller.setCampaignImagePath(pickedFile!.path);
      //Navigator.of(Get.overlayContext!).pop(); // Close the bottom sheet
    }
  }

  Future<void> takeCarPhoto(ImageSource source) async {
    final pickedImage =
        await imagePicker.pickImage(source: source, imageQuality: 100);
    if (pickedImage != null) {
      final String imagePath = pickedImage.path;
      _controller.setCarImageImagePath(imagePath);
      _controller_deposit.setCarImageImagePath(imagePath);
    }
  }
}
