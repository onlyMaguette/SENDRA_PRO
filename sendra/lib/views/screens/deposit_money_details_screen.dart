import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:walletium/controller/deposit_money_details_controller.dart';
import 'package:walletium/utils/custom_color.dart';
import 'package:walletium/utils/size.dart';
import 'package:walletium/utils/strings.dart';
import 'package:walletium/widgets/others/back_button_widget.dart';

import '../../controller/deposit_controller.dart';

class DepositMoneyDetailsScreen extends StatefulWidget {
  DepositMoneyDetailsScreen({Key? key}) : super(key: key);

  @override
  _DepositMoneyDetailsScreenState createState() =>
      _DepositMoneyDetailsScreenState();
}

class _DepositMoneyDetailsScreenState extends State<DepositMoneyDetailsScreen> {
  final _controller = Get.put(DepositMoneyDetailsController());
  final _controller_deposit = Get.put(DepositController());

  late Future<Map<String, dynamic>> signalementDataFuture = Future.value({});
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      fetchSignalementData();
      //getUserData();
    });
  }
  Future<Map<String, dynamic>> fetchSignalementDetails(int signalementId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = Strings.apiURI + 'listerSignalement/$signalementId';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      // Vérifier si la clé "data" existe dans la réponse JSON
      if (jsonResponse.containsKey('data')) {
        // Accéder à la liste associée à la clé "data"
        final dataList = jsonResponse['data'];
        // Vérifier si la liste contient au moins un élément
        if (dataList.isNotEmpty) {
          // Récupérer le premier élément de la liste
          final data = dataList[0];
          return data;
        } else {
          throw Exception('Aucune donnée n\'a été trouvée pour ce signalement');
        }
      } else {
        throw Exception('Clé "data" manquante dans la réponse JSON');
      }
    } else {
      throw Exception('Impossible d\'afficher les détails du signalement');
    }
  }


  Future<void> fetchSignalementData() async {
    try {
      final signalementId = ModalRoute.of(context)!.settings.arguments.toString();
      signalementDataFuture = fetchSignalementDetails(int.parse(signalementId));
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      // Handle error
      print('Erreurr: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          Strings.details,
          style: TextStyle(color: CustomColor.whiteColor),
        ),
        leading: const BackButtonWidget(
          backButtonImage: Strings.backButtonWhite,
        ),
        backgroundColor: CustomColor.primaryColor,
        elevation: 0,
      ),
      body: isLoading
          ? _buildLoading()
          : FutureBuilder<Map<String, dynamic>>(
        future: signalementDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoading();
          } else if (snapshot.hasError) {
            print('Erreur: ${snapshot.error}');
            return _buildError();
          } else if (snapshot.hasData) {
            return _buildContent(snapshot.data!);
          } else {
            return _buildError();
          }
        },
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> signalementData) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _detailsWidget(signalementData),
          SizedBox(height: 20.h),
          _MapWidget(signalementData),
          SizedBox(height: 20.h),
          _ImageDetailWidget(signalementData),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Text(
        'Echec du chargement des détails du signalement.',
        style: TextStyle(
          color: Colors.red,
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _ImageDetailWidget(Map<String, dynamic> signalementData) {
    final imageUrl = signalementData['image_url'];

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Hero(
          tag: imageUrl, // Utilisez une URL unique comme tag
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: GestureDetector(
              onTap: () {
                // Naviguer vers l'écran de l'image en plein écran
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FullScreenImage(imageUrl: imageUrl),
                  ),
                );
              },
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 300.0,
              ),
            ),
          ),
        ),
      );
    } else {
      return Placeholder(
        fallbackHeight: 200.0,
        fallbackWidth: double.infinity,
      );
    }
  }

  Widget _MapWidget(Map<String, dynamic> signalementData) {
    final latitude = double.parse(signalementData['latitude'] ?? '0.0');
    final longitude = double.parse(signalementData['longitude'] ?? '0.0');
    final etat = signalementData['etat'] as String?;

    // Définir la couleur du marqueur en fonction de l'état
    Color markerColor;
    switch (etat) {
      case 'SIGNALE':
        markerColor = Colors.red;
        break;
      case 'EN COURS':
        markerColor = Colors.orange;
        break;
      case 'ENLEVE':
        markerColor = Colors.green;
        break;
      default:
        markerColor = Colors.black; // Couleur par défaut si l'état n'est pas défini
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200.0,
              child: FlutterMap(
                options: MapOptions(
                  center: LatLng(latitude, longitude),
                  zoom: 13.0,
                ),
                layers: [
                  TileLayerOptions(
                    urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayerOptions(
                    markers: [
                      Marker(
                        width: 40.0,
                        height: 40.0,
                        point: LatLng(latitude, longitude),
                        builder: (ctx) => Container(
                          child: Icon(
                            Icons.location_on,
                            color: markerColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Carte de localisation',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Zoomez pour voir l\'emplacement',
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailsWidget(Map<String, dynamic> signalementData) {
    final titre = signalementData['titre'] as String?;
    final commune = signalementData['commune'] as String?;
    final etat = signalementData['etat'] as String?;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre avec une police en gras et une couleur vive
          Text(
            titre ?? '',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.black, // Exemple de couleur vive
            ),
          ),
          SizedBox(height: 8),
          // Commune avec une police plus légère
          Text(
            commune ?? '',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey, // Exemple de couleur plus légère
            ),
          ),
          SizedBox(height: 16),
          // État avec une icône et une couleur correspondante
          Row(
            children: [
              if (etat == 'ENLEVE')
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                )
              else if (etat == 'EN COURS') // Nouvelle condition pour l'état en cours
                Icon(
                  Icons.pending_actions,
                  color: Colors.orange,
                )
              else
                Icon(
                  Icons.warning,
                  color: Colors.red,
                ),
              SizedBox(width: 8),
              Text(
                etat == 'ENLEVE'
                    ? 'Résolu'
                    : etat == 'EN COURS' // Nouvelle condition pour l'état en cours
                    ? 'En cours'
                    : 'Signalé',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: etat == 'EN COURS' // Nouvelle condition pour l'état en cours
                      ? Colors.orange
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Nouvel écran pour afficher l'image en plein écran
class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*
      appBar: AppBar(
        // Ajoutez un bouton de retour dans l'appBar
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

       */
      backgroundColor: Colors.black,
      body: Center(
        child: Hero(
          tag: imageUrl,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            // Assurez-vous que l'image est centrée et remplie l'écran
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
        ),
      ),
    );
  }
}
