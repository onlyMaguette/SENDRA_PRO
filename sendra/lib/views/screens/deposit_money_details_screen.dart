import 'dart:convert';

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

  late Future<Map<String, dynamic>> signalementDataFuture;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      fetchSignalementData();
    });
  }

  Future<Map<String, dynamic>> fetchSignalementDetails(
      int signalementId) async {
    final url = Strings.apiURL + 'detail.php'; // Replace with your PHP API URL
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'signalementId': signalementId});

    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);
    print(response);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Impossible d\'afficher les détails du signalement');
    }
  }

  Future<void> fetchSignalementData() async {
    try {
      final signalementId =
          ModalRoute.of(context)!.settings.arguments.toString();
      signalementDataFuture = fetchSignalementDetails(int.parse(signalementId));
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      // Handle error
      print('Error: $e');
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
          Strings.depositMoneyDetails,
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
    return ListView(
      children: [
        _detailsWidget(signalementData),
        _MapWidget(signalementData),
        addVerticalSpace(20.h),
        _ImageDetailWidget(signalementData),
        addVerticalSpace(20.h),
      ],
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
        'Failed to load signalement details.',
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
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
      );
    } else {
      return Placeholder(
        fallbackHeight: 200.0,
        fallbackWidth: double.infinity,
      );
    }
  }

  Widget _MapWidget(Map<String, dynamic> signalementData) {
    final latitude = double.parse(signalementData['latitude']);
    final longitude = double.parse(signalementData['longitude']);

    return SizedBox(
      width: double.infinity,
      height: 300.0,
      child: FlutterMap(
        options: MapOptions(
          center: LatLng(latitude, longitude),
          zoom: 13.0,
        ),
        layers: [
          TileLayerOptions(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailsWidget(Map<String, dynamic> signalementData) {
    final titre = signalementData['titre'] as String?;
    final commune = signalementData['commune'] as String?;

    return Column(
      children: [
        ListTile(
          title: Text(
            titre ?? '',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            commune ?? '',
            style: TextStyle(fontSize: 16.0),
          ),
        ),
      ],
    );
  }
}
