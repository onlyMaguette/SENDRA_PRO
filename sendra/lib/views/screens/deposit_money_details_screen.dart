import 'dart:convert';


import '../../utils/strings.dart';
import 'approbation_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:walletium/controller/deposit_controller.dart';
import 'package:walletium/controller/deposit_money_details_controller.dart';
import 'enlevement_screen.dart';
import 'dommages_screen.dart';
import 'infraction_screen.dart';
import 'vehicule_screen.dart';
import 'informationBase_screen.dart';

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
  Map<String, dynamic> signalementData = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      fetchSignalementData();
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
      if (jsonResponse.containsKey('data')) {
        final dataList = jsonResponse['data'];
        if (dataList.isNotEmpty) {
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
      signalementData = await signalementDataFuture;
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Erreur: $e');
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
          'Constatation',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.green,
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
          _localisationButton(),
          _menuItem('Informations de base', signalementData),
          _menuItem('Véhicule'),
          _menuItem('Infraction'),
          _menuItem('Dommages'),
          _menuItem('Approbation'),
          _menuItem('Enlèvement'),
        ],
      ),
    );
  }

  Widget _localisationButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton.icon(
        onPressed: () {
          // Ajouter ici l'action pour le bouton de localisation
        },
        icon: Icon(Icons.location_on),
        label: Text('Localisation'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16.0),
          textStyle: TextStyle(fontSize: 18.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
    );
  }

  Widget _menuItem(String title, [Map<String, dynamic>? signalementData]) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: ListTile(
          title: Text(title),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () {
            if (title == 'Informations de base') {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => BasicInfoForm(
                  signalementData: signalementData!,
                ),
              ));
            } else if (title == 'Véhicule') {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => VehicleForm(),
              ));
            } else if (title == 'Infraction') {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => InfractionForm(),
              ));
            } else if (title == 'Dommages') {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => DommagesScreen(signalementId: signalementData!['signalementId']),
              ));
            }
            else if (title == 'Approbation') {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ApprovalForm(),
              ));
            } else if (title == 'Enlèvement') {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => RemovalForm(),
              ));
            }
          },
        ),
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
        'Échec du chargement des détails du signalement.',
        style: TextStyle(
          color: Colors.red,
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}












