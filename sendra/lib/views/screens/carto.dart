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
        Uri.parse(Strings.apiURL + 'historique.php?action=getSignalements'));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
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
            Strings.depositMoneyDetails,
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
      layers: [
        TileLayerOptions(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c'],
        ),
        MarkerLayerOptions(
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
                    builder: (ctx) => GestureDetector(
                      onTap: () {
                        showDialog(
                          context: ctx,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('${signalement['titre']}'),
                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('${signalement['commune']}'),
                                  Text('${signalement['formatted_date']}'),
                                  SizedBox(height: 10),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, '/depositMoneyDetailsScreen',
                                          arguments: signalement['id']);
                                    },
                                    child: Row(
                                      children: [
                                        Icon(Icons.remove_red_eye), // Eye icon
                                        SizedBox(width: 8),
                                        Text('Voir les détails'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: Icon(Icons.location_on, color: Colors.red),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
