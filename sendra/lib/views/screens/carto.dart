import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../../utils/custom_color.dart';
import '../../utils/strings.dart';
import '../../widgets/others/back_button_widget.dart';

class CartoScreen extends StatefulWidget {
  const CartoScreen({Key? key}) : super(key: key);

  @override
  _CartoScreenState createState() => _CartoScreenState();
}

class _CartoScreenState extends State<CartoScreen> {
  List<Map<String, dynamic>> signalements = [];

  @override
  void initState() {
    super.initState();
    _fetchSignalements();
  }

  Future<void> _fetchSignalements() async {
    final response = await http.get(
      Uri.parse(Strings.apiURI + 'listerSignalements'),
    );

    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      List<dynamic> jsonResponse = responseData['data'];
      print(jsonResponse);
      setState(() {
        signalements = List<Map<String, dynamic>>.from(jsonResponse);
      });
    } else {
      print('Failed to fetch data: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            Strings.cartoDetails,
            style: TextStyle(color: CustomColor.whiteColor),
          ),
          leading: const BackButtonWidget(
            backButtonImage: Strings.backButtonWhite,
          ),
          backgroundColor: CustomColor.primaryColor,
          elevation: 0,
        ),
        body: SignalementMap(signalements: signalements),
      ),
    );
  }
}

class SignalementMap extends StatelessWidget {
  final List<Map<String, dynamic>> signalements;

  SignalementMap({required this.signalements});

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        center: LatLng(14.7488, -17.3909), // Pikine's coordinates
        zoom: 10, // Zoom level
      ),
      children: [ // Utilisation du paramètre children pour spécifier les couches de la carte
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c'],
        ),
        MarkerLayer(
          markers: signalements
              .where((signalement) =>
          signalement['latitude'] != null &&
              signalement['longitude'] != null)
              .map((signalement) => Marker(
            width: 80.0,
            height: 80.0,
            point: LatLng(
              double.parse(signalement['latitude'].toString()),
              double.parse(signalement['longitude'].toString()),
            ),
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        // Bordures arrondies
                      ),
                      title: Text(
                        '${signalement['titre']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Commune : ${signalement['commune']}',
                            style: TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                          Text(
                            'Date : ${signalement['formatted_date']}',
                            style: TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                          SizedBox(height: 20),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/depositMoneyDetailsScreen',
                                arguments: signalement['signalementId'],
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius:
                                BorderRadius.circular(8.0),
                                // Bordures arrondies pour le bouton
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.remove_red_eye,
                                    color: Colors.white,
                                    // Couleur de l'icône en blanc
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Voir les détails',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      // Couleur du texte en blanc
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: Icon(
                Icons.location_on,
                color: _getMarkerColor(signalement['etat']),
                // Couleur basée sur l'état du signalement
              ),
            ),
          ))
              .toList(),
        ),
      ],
    );
  }


  Color _getMarkerColor(String etat) {
    switch (etat) {
      case 'SIGNALE':
        return Colors.red;
      case 'EN COURS':
        return Colors.orange;
      case 'ENLEVE':
        return Colors.green;
    // Couleur orange pour l'état EN_COURS
      default:
        return Colors.black;
    }
  }
}
