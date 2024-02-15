import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:walletium/utils/custom_color.dart';
import 'package:walletium/utils/dimsensions.dart';
import 'package:walletium/utils/strings.dart';
import 'package:walletium/widgets/others/back_button_widget.dart';

class TransactionsHistoryScreen extends StatefulWidget {
  const TransactionsHistoryScreen({Key? key}) : super(key: key);

  @override
  _TransactionsHistoryScreenState createState() =>
      _TransactionsHistoryScreenState();
}

class _TransactionsHistoryScreenState extends State<TransactionsHistoryScreen> {
  List<dynamic> transactions = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    List<dynamic> fetchedSignalements = await fetchSignalements();

    setState(() {
      transactions = fetchedSignalements;
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
      appBar: AppBar(
        title: const Text(
          Strings.transactionsHistory,
          style: TextStyle(color: CustomColor.whiteColor),
        ),
        leading: const BackButtonWidget(
          backButtonImage: Strings.backButtonWhite,
        ),
        backgroundColor: CustomColor.primaryColor,
        elevation: 0,
      ),
      body: _bodyWidget(context, transactions),
    );
  }

  ListView _bodyWidget(BuildContext context, List<dynamic> transactions) {
    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: transactions.length,
      itemBuilder: (BuildContext context, int index) {
        final transaction = transactions[index];
        final titre = transaction['titre'] ?? 'Unknown';
        final date = transaction['formatted_date'] ?? 'Unknown';
        final imageUrl = transaction['image_url'];
        final commune = transaction['commune'];

        return GestureDetector(
          onTap: () {
            // Navigate to the detail page with the transaction ID
            Navigator.pushNamed(context, '/depositMoneyDetailsScreen',
                arguments: transaction['id']);
          },
          child: SizedBox(
            height: 100,
            child: Padding(
              padding: EdgeInsets.all(Dimensions.defaultPaddingSize * 0.3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (imageUrl != null)
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(40), // Make the image round
                      child: Image.network(
                        imageUrl,
                        height: 80, // Increase image size
                        width: 80, // Increase image size
                        fit: BoxFit.cover, // Adjust the fit as needed
                      ),
                    ),
                  SizedBox(width: 20.w),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                          height: 5), // Adding margin between image and titre
                      Text(
                        titre,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        commune,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Text(
                        date,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
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
