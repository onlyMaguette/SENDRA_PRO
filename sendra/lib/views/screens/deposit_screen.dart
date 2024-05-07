import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  File? _selectedImageFile;

  Position? locationData;
  String locality = '';
  String subLocality = '';
  String? image;
  double? latitude;
  double? longitude;

  bool _isLoading = false;

  Future<void> getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        locationData = null;
      });
      return;
    }

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

    Position currentPosition = await Geolocator.getCurrentPosition();
    latitude = currentPosition.latitude;
    longitude = currentPosition.longitude;
    setState(() {
      locationData = currentPosition;
    });

    if (locationData != null) {
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

  Future<void> _submitImage(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      print('Le token n\'a pas été récupéré correctement depuis SharedPreferences');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Convertir l'image en base64
    List<int> imageBytes = await _selectedImageFile!.readAsBytes();
    String base64Image = base64.encode(imageBytes);

    var request = http.MultipartRequest(
      'POST', Uri.parse(Strings.apiURI + 'faireSignalement'),
    );

    request.fields['titre'] = _controller.titreController.text;
    await getLocation();
    request.fields['commune'] = '$locality';
    request.fields['latitude'] = '$latitude';
    request.fields['longitude'] = '$longitude';

    // Ajouter l'image en tant que champ de formulaire ordinaire avec la chaîne base64
    request.fields['image'] = base64Image;

    request.headers['Authorization'] = 'Bearer $token';

    try {
      final response = await request.send();
      print(response.statusCode);
      print(response);

      print(token);

      if (response.statusCode == 200) {
        setState(() {
          _isLoading = false;
          _controller.titreController.text = '';
        });

        // Show confirmation snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Votre signalement a été pris en compte !'),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.symmetric(horizontal: 40),
          ),
        );

        // Navigate to the specified route
        Get.toNamed(Routes.bottomNavigationScreen);
      } else {
        print('Erreur lors de la signalisation');
      }
    } catch (e) {
      print('Erreur lors de la connexion au serveur');
      showErrorMessage('Une erreur s’est produite: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  void showErrorMessage(String message) {
    final snackBar = SnackBar(
      content: Text(message),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _selectImage() async {
    final picker = ImagePicker();

    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Choisissez la source de l\'image'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                foregroundColor: CustomColor.whiteColor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library),
                  SizedBox(width: 10),
                  Text('Galerie'),
                ],
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(ImageSource.camera),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                foregroundColor: CustomColor.whiteColor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt),
                  SizedBox(width: 10),
                  Text('Appareil photo'),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (source == null) {
      return;
    }
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile == null) {
      return;
    }
    setState(() {
      _selectedImageFile = File(pickedFile.path);
    });

    // Show preview dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Variable pour suivre l'état de chargement
        bool isLoading = false;

        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return Center(
              child: isLoading
                  ? CircularProgressIndicator() // Afficher l'indicateur de chargement si isLoading est vrai
                  : AlertDialog(
                title: Text(
                  'Confirmation',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.green, // Couleur bleue pour le titre
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0), // Coins arrondis
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Container(
                        width: 200.0, // Ajustez la largeur de l'image comme vous le souhaitez
                        height: 200.0, // Ajustez la hauteur de l'image comme vous le souhaitez
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 3,
                              blurRadius: 7,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: _selectedImageFile != null ? Image.file(_selectedImageFile!, fit: BoxFit.cover) : SizedBox.shrink(),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Confirmez-vous la sélection de cette image ?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold, // Texte en gras
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Fermer la boîte de dialogue
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red, // Changer la couleur du bouton en rouge
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0), // Bordures arrondies pour le bouton
                            ),
                          ),
                          child: Text('Annuler'),

                        ),
                        ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              isLoading = true; // Définir isLoading à true pour afficher l'indicateur de chargement
                            });
                            showDialog(
                              barrierDismissible: false, // Empêche la fermeture du dialog en cliquant en dehors de celui-ci
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue), // Couleur du spinner
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Signalement en cours...',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        'Veuillez patienter pendant que nous traitons votre signalement.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                            _submitImage('token');
                            // Ne pas fermer la boîte de dialogue ici, elle devrait probablement être fermée une fois que le processus de soumission est terminé.
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green, // Changer la couleur du bouton en BlueGrey
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0), // Bordures arrondies pour le bouton
                            ),
                          ),
                          child: isLoading
                              ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 24, // Ajustez la largeur pour le spinner
                                height: 24, // Ajustez la hauteur pour le spinner
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white), // Couleur du spinner
                                ),
                              ),
                              SizedBox(height: 8), // Espacement entre le spinner et le texte
                              Text(
                                'Signalement en cours...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                              : Text(
                            'Confirmer',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),




                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
        _continueButtonWidget(context),
        addVerticalSpace(20.h),
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
            margin: EdgeInsets.symmetric(horizontal: Dimensions.marginSize * 0.5),
            child: TextFormField(
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              cursorColor: Colors.black,
              controller: _controller.titreController,
              decoration: InputDecoration(
                hintText: 'Que voulez-vous signaler ?',
                hintStyle: TextStyle(color: CustomColor.gray),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: CustomColor.whiteColor,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez saisir un titre.';
                }
                return null;
              },
            ),
          ),
          addVerticalSpace(20.h),
        ],
      ),
    );
  }

  Widget _continueButtonWidget(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 30.0),
          child: ElevatedButton(
            onPressed: () {
              if (!_isLoading) {
                // Vérifier si le chargement est déjà en cours
                if (_controller.formKey.currentState!.validate()) {
                  setState(() {
                    _isLoading = false; // Définir l'état de chargement sur vrai
                  });
                  _selectImage(); // Appel à la méthode de sélection de l'image
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CustomColor.primaryColor, // couleur de fond du bouton
              foregroundColor: CustomColor.whiteColor, // couleur du texte
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0), // bordure arrondie
              ),
              elevation: 3, // élévation pour ajouter de la profondeur
              padding: EdgeInsets.symmetric(vertical: 12.0), // ajuster le rembourrage vertical
            ),
            child:_isLoading
                ? SizedBox(
              // Afficher un spinner si le chargement est en cours
              width: 24.0,
              height: 24.0,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt,
                  size: 24.0,
                  color: Colors.white,
                ),
                SizedBox(width: 10.0), // espace supplémentaire entre l'icône et le texte
                Text(
                  Strings.signaler,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold, // rendre le texte en gras
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 10.0), // ajouter un espace vertical
        Text(
          'Cliquez sur "Signaler" pour prendre une photo',
          style: TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
