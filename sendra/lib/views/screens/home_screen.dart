import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:walletium/utils/custom_color.dart';
import 'package:walletium/utils/custom_style.dart';
import 'package:walletium/utils/dimsensions.dart';
import 'package:walletium/utils/size.dart';
import 'package:walletium/utils/strings.dart';
import 'package:walletium/views/screens/drawer_screen.dart';

import '../../routes/routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> signalements = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    List<dynamic> fetchedSignalements = await fetchSignalements();

    setState(() {
      signalements = fetchedSignalements;
    });
  }

  Future<List<dynamic>> fetchSignalements() async {
    final response = await http.get(
        Uri.parse(Strings.apiURL + 'historique.php?action=getSignalements'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Erreur lors de la récupération des signalements');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.primaryBackgroundColor,
      drawer: const DrawerScreen(),
      appBar: AppBar(
        backgroundColor: CustomColor.primaryColor,
        iconTheme: const IconThemeData(color: CustomColor.whiteColor),
        title: const Text(Strings.dashboard),
        elevation: 0,
      ),
      body: _bodyWidget(context),
    );
  }

  Widget _bodyWidget(BuildContext context) {
    return ListView(
      children: [
        if (signalements.isNotEmpty)
          CarouselSlider(
            options: CarouselOptions(
              height: 200.0,
              autoPlay: true,
              aspectRatio: 16 / 9,
              autoPlayInterval: const Duration(seconds: 3),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              enableInfiniteScroll: true,
              autoPlayCurve: Curves.fastOutSlowIn,
            ),
            items: signalements.map<Widget>((signalement) {
              final imageUrl = signalement['image_url'] as String?;
              final etat = signalement['etat'] as String?;
              final createdDate = signalement['formatted_date'] as String?;
              final color = etat == 'SIGNALE' ? Colors.red : Colors.green;
              final commune = signalement['commune'] as String?;

              return Builder(
                builder: (BuildContext context) {
                  return imageUrl != null
                      ? InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                                context, '/depositMoneyDetailsScreen',
                                arguments: signalement['id']);
                          },
                          child: Stack(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5.0),
                                decoration: BoxDecoration(
                                  color: Colors.grey, // Placeholder color
                                  borderRadius: BorderRadius.circular(8.0),
                                  image: DecorationImage(
                                    image: NetworkImage(imageUrl),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 6.0,
                                left: 6.0,
                                child: Container(
                                  padding: const EdgeInsets.all(6.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4.0),
                                    color: Colors.black.withOpacity(0.7),
                                  ),
                                  child: Text(
                                    commune ?? 'Commune not available',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              Positioned(
                                top:
                                    6.0, // Adjust the position of the point as needed
                                right:
                                    6.0, // Adjust the position of the point as needed
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: color,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 6.0,
                                right: 6.0,
                                child: Container(
                                  padding: const EdgeInsets.all(6.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4.0),
                                    color: Colors.black.withOpacity(0.7),
                                  ),
                                  child: Text(
                                    createdDate ?? 'Date not available',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(); // Placeholder when imageUrl is null
                },
              );
            }).toList(),
          ),
        // Your remaining widgets...
        _smallContainerWidget(context),
        // Existing code for transaction history
        if (signalements.length > 0)
          _transactionHistoryWidget(context, signalements),
      ],
    );
  }

  Container _smallContainerWidget(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(Dimensions.marginSize),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              Get.toNamed(Routes.depositScreen);
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.green, // Set the primary color
              onPrimary: Colors.white, // Set the text color
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(20.0), // Adjust the border radius
              ),
              padding: EdgeInsets.symmetric(
                vertical: 12.0, // Adjust vertical padding
                horizontal: 24.0, // Adjust horizontal padding
              ),
              elevation: 4, // Add elevation for a subtle shadow
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min, // Align items to the center
              children: [
                Icon(
                  FontAwesomeIcons.plus, // Modify icon if required
                  color: Colors.white,
                ),
                SizedBox(width: 8), // Add space between icon and text
                Text(
                  Strings.deposit,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16, // Adjust text size if needed
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container _transactionHistoryWidget(
      BuildContext context, List<dynamic> signalements) {
    return Container(
      // margin: EdgeInsets.all(Dimensions.marginSize),
      padding: EdgeInsets.all(Dimensions.defaultPaddingSize * 0.5),
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 254, 254, 1),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          topLeft: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 30.w,
            height: 5.h,
            decoration: BoxDecoration(
              color: CustomColor.primaryColor,
              borderRadius: BorderRadius.circular(15.r),
            ),
          ),
          addVerticalSpace(20.h),
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(
                horizontal: Dimensions.defaultPaddingSize * 0.3),
            child: Text(
              Strings.transactionsHistory,
              style: CustomStyler.transactionsHistoryStyle,
            ),
          ),
          addVerticalSpace(5.h),
          FutureBuilder<List<dynamic>>(
            future: fetchSignalements(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return _transactionHistoryListWidget(context, snapshot.data!);
              } else if (snapshot.hasError) {
                return Text('Erreur lors de la récupération des signalements');
              } else {
                return CircularProgressIndicator(); // Afficher un indicateur de chargement en attendant les données
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _transactionHistoryListWidget(
      BuildContext context, List<dynamic> signalements) {
    return signalements.isEmpty
        ? Center(
            child: CircularProgressIndicator(), // Loading spinner
          )
        : ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: signalements.length,
            itemBuilder: (BuildContext context, int index) {
              final signalement = signalements[index];
              final monSignal = signalement['id'];

              return GestureDetector(
                onTap: () {
                  // Redirect to the detail page using the signalement ID
                  Navigator.pushNamed(
                    context,
                    '/depositMoneyDetailsScreen',
                    arguments: signalement['id'],
                  );
                },
                child: SizedBox(
                  height: 100, // Increase the container height
                  child: Padding(
                    padding:
                        EdgeInsets.all(Dimensions.defaultPaddingSize * 0.3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (signalement['image_url'] != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                                40), // Make the image round
                            child: Image.network(
                              signalement['image_url'],
                              height: 80, // Increase image size
                              width: 80, // Increase image size
                              fit: BoxFit.cover, // Adjust the fit as needed
                            ),
                          ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                signalement['titre'] ?? '',
                                style: TextStyle(
                                  color: Colors.black, // Adjust text color
                                  fontSize: 18, // Adjust font size as needed
                                ),
                              ),
                              Text(
                                signalement['commune'] ?? '',
                                style: TextStyle(
                                  color: Colors.black, // Adjust text color
                                  fontSize: 14, // Adjust font size as needed
                                ),
                              ),
                              Text(
                                signalement['formatted_date'] ?? '',
                                style: TextStyle(
                                  color: Colors.black, // Adjust text color
                                  fontSize: 14, // Adjust font size as needed
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: signalement['etat'] == 'SIGNALE'
                                    ? Colors.red
                                    : Colors.green,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          signalement['created_date'] ??
                              '', // Use the correct date field
                          style: TextStyle(
                            color: Colors.black, // Adjust text color
                            fontSize: 14, // Adjust font size as needed
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
  }
}
