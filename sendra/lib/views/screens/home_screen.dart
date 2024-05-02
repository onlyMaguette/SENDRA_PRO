import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../routes/routes.dart';
import '../../utils/custom_color.dart';
import '../../utils/custom_style.dart';
import '../../utils/dimsensions.dart';
import '../../utils/size.dart';
import '../../utils/strings.dart';
import '../screens/drawer_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class Statistics {
  int totalReports = 0;
  int resolvedReports = 0;
  int ongoingReports = 0;
  int reportedReports = 0; // Ajouter un champ pour les signalements signalés

  Statistics({
    required this.totalReports,
    required this.resolvedReports,
    required this.ongoingReports,
    required this.reportedReports,
  });
}

class Slide {
  final String title;
  final String description;
  final IconData icon;

  Slide({required this.title, required this.description, required this.icon});
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> allSignalements = [];
  bool _isLoading = false;
  bool _hasNextPage = false;
  bool _allSlidesSeen = false;


  // Déclarez une variable pour suivre l'index de la diapositive actuelle
  int _currentPageIndex = 0;

  // Fonction pour mettre à jour l'index de la diapositive actuelle
  void _updateCurrentPageIndex(int index) {
    setState(() {
      _currentPageIndex = index;
      if (_currentPageIndex == slides.length - 1) {
        _allSlidesSeen = true;
      } else {
        _allSlidesSeen = false;
      }
    });
  }


  late Statistics statistics =
  Statistics(totalReports: 0, resolvedReports: 0, ongoingReports: 0, reportedReports: 0);

  late SharedPreferences _prefs;
  bool _showSlides = true;
  bool _showScrollIndicator = true; // Définition de la variable ici
  double _scrollIndicatorPosition = 0; // Position initiale de l'indicateur de défilement
  bool _scrolling = false; // Variable pour indiquer si le défilement est en cours
  double _lastScrollIndicatorPosition = 0.0; // Dernière position de l'indicateur

  late String nextPageUrl;
  String token = '';

  @override
  void initState() {
    super.initState();
    _initPrefs();
    _fetchData();
    getUserData();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    final bool hasSeenSlides = _prefs.getBool('hasSeenSlides') ?? false;
    setState(() {
      _showSlides = !hasSeenSlides;
    });
  }

  Future<void> _fetchData() async {
    try {
      List<dynamic> fetchedSignalements = await fetchSignalements();
      Statistics fetchedStatistics = await fetchStatistics();
      setState(() {
        allSignalements = fetchedSignalements;
        statistics = fetchedStatistics;
      });
    } catch (e) {
      // Handle errors
    }
  }

  Future<Statistics> fetchStatistics() async {
    final response = await http.get(Uri.parse(Strings.apiURI + 'statistiques'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Statistics(
        totalReports: data['signalements'],
        resolvedReports: data['enleves'],
        ongoingReports: data['signales'],
        reportedReports: data['encours'], // Assurez-vous que 'signales' correspond au champ renvoyé par votre API pour les signalements signalés
      );
    } else {
      throw Exception('Error fetching statistics');
    }
  }

  Future<void> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token') ?? 'No name';
    });
  }

  Future<List<dynamic>> fetchSignalements() async {
    final response = await http.get(
      Uri.parse(Strings.apiURI + 'listerSignalements'),
      headers: <String, String>{
        "Content-Type": "application/json",
        'Authorization': 'Bearer ' + token,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _hasNextPage = data['links']['next'] != null;
        nextPageUrl = data['links']['next'] ?? '';
      });
      return data['data'];
    } else {
      throw Exception('Error fetching signalements');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _showSlides ? _buildIntroSlides() : _buildHomeScreen();
  }

  final List<Slide> slides = [
    Slide(
      title: "Bienvenue sur l'application",
      description: "Découvrez les fonctionnalités et les informations importantes sur notre application.",
      icon: Icons.mobile_screen_share,
    ),
    Slide(
      title: "Statistiques des signalements",
      description: "Consultez les statistiques en temps réel sur les signalements : total, résolus, en cours et signalés.",
      icon: Icons.insert_chart_outlined,
    ),
    Slide(
      title: "Historique des signalements",
      description: "Explorez l'historique détaillé des signalements avec leurs états et leurs détails.",
      icon: Icons.history,
    ),
    Slide(
      title: "Effectuer un signalement",
      description: "Signalez facilement les problèmes en prenant des photos et en fournissant des détails pour une action rapide.",
      icon: Icons.report_problem,
    ),
    Slide(
      title: "Voir les détails des signalements",
      description: "Consultez les détails complets de chaque signalement, y compris l'état actuel et l'historique des actions.",
      icon: Icons.info,
    ),
    Slide(
      title: "Visualiser sur la carte",
      description: "Explorez les signalements sur une carte interactive pour une vue d'ensemble géographique.",
      icon: Icons.map,
    ),
  ];

  Widget _buildIntroSlides() {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            itemCount: slides.length,
            onPageChanged: _updateCurrentPageIndex,
            itemBuilder: (context, index) {
              final slide = slides[index];
              return _buildSlide(slide);
            },
          ),
          Positioned(
            bottom: 40,
            right: 20,
            child: ElevatedButton(
              onPressed: _closeSlides,
              child: Text(
                'Commencer',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF1B5E20), // Vert foncé
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // Blanc
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Color(0xFF1B5E20)), // Bordure vert foncé
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 180,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildPageIndicators(),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSlide(Slide slide) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            slide.icon,
            size: 100,
            color: Color(0xFF1B5E20), // Vert foncé
          ),
          SizedBox(height: 20),
          Text(
            slide.title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20), // Vert foncé
            ),
          ),
          SizedBox(height: 10),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              slide.description,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Color(0xFF1B5E20)), // Vert foncé
            ),
          ),
        ],
      ),
    );
  }

  // Fonction pour construire les indicateurs de pagination
  List<Widget> _buildPageIndicators() {
    List<Widget> indicators = [];
    for (int i = 0; i < slides.length; i++) {
      indicators.add(
        Container(
          width: 10,
          height: 10,
          margin: EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPageIndex == i ? Colors.green : Colors.grey, // Couleur différente pour la diapositive actuelle
          ),
        ),
      );
    }
    return indicators;
  }

  Future<void> _closeSlides() async {
    if (_allSlidesSeen) {
      await _prefs.setBool('hasSeenSlides', true);
      setState(() {
        _showSlides = false;
      });
    } else {
      // Affichez un message à l'utilisateur pour lui indiquer de voir tous les slides.

      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar
        (
           content: Text('Veuillez parcourir tous les slides avant de continuer.'),
        ),
      );
    }
  }


  void _showSlidesAgain() async {
    await _prefs.setBool('hasSeenSlides', false);
    setState(() {
      _showSlides = true;
    });
  }

  Widget _buildHomeScreen() {
    return Scaffold(
      backgroundColor: CustomColor.primaryBackgroundColor,
      drawer: const DrawerScreen(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Colors.grey, Colors.green[900]!],
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: CustomColor.whiteColor),
        title: Center(
          child: Image.asset(
            'assets/images/EPAVIE2.png',
            fit: BoxFit.contain,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.slideshow),
            onPressed: _showSlidesAgain,
          ),
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  child: contentBox(context),
                ),
              );
            },
          ),
        ],
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (scrollNotification is ScrollStartNotification) {
            setState(() {
              _scrolling = true;
            });
          } else if (scrollNotification is ScrollEndNotification) {
            setState(() {
              _scrolling = false;
            });
            if (scrollNotification.metrics.pixels ==
                scrollNotification.metrics.maxScrollExtent) {
              _loadMoreSignalements();
            }
          } else if (scrollNotification is ScrollUpdateNotification) {
            setState(() {
              _scrollIndicatorPosition = scrollNotification.metrics.pixels;
            });
          }
          return true;
        },
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    margin: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem('Total', statistics.totalReports),
                        _buildStatItem('Résolus', statistics.resolvedReports),
                        _buildStatItem('Signalés', statistics.ongoingReports),
                        _buildStatItem('En Cours', statistics.reportedReports),
                      ],
                    ),
                  ),
                  _smallContainerWidget(context),
                  if (allSignalements.isNotEmpty)
                    _transactionHistoryWidget(context, allSignalements),
                ],
              ),
            ),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              child: Visibility(
                visible: _showScrollIndicator,
                child: Container(
                  width: 4.0,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    color: Colors.white60.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Align(
                    alignment: Alignment(1, _calculateIndicatorPosition()),
                    child: Container(
                      width: 4.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget contentBox(context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                offset: Offset(0, 10),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Information',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 15),
              Text(
                'Les signalements expirent après 10 jours. Après ce délai, pour découvrir de nouveaux signalements, n\'hésitez pas à en effectuer vous-même ou patientez jusqu\'à ce qu\'un autre utilisateur le fasse.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 22),
              Align(
                alignment: Alignment.bottomCenter,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'OK',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }






  void _updateScrollIndicatorPosition(double position) {
    setState(() {
      _lastScrollIndicatorPosition = position;
      _showScrollIndicator = true;
    });
  }

  double _calculateIndicatorPosition() {
    double maxScrollExtent = MediaQuery.of(context).size.height;
    double totalHeight = _getListTotalHeight();

    if (_scrolling) {
      double scrollPosition = _scrollIndicatorPosition.clamp(0.0, totalHeight);
      return scrollPosition / totalHeight;
    } else {
      return _scrollIndicatorPosition / totalHeight;
    }
  }

  double _getListTotalHeight() {
    double totalHeight = 0;
    for (dynamic signalement in allSignalements) {
      totalHeight += 120;
    }
    return totalHeight;
  }

  void _loadMoreSignalements() async {
    if (!_isLoading && _hasNextPage) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await http.get(Uri.parse(nextPageUrl), headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer ' + token,
        });

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          setState(() {
            allSignalements.addAll(data['data']);
            _hasNextPage = data['links']['next'] != null;
            nextPageUrl = data['links']['next'] ?? '';
            _isLoading = false;
          });
        } else {
          throw Exception('Error fetching more signalements');
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        // Handle error
      }
    }
  }

  Widget _smallContainerWidget(BuildContext context) {
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
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              padding: EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 24.0,
              ),
              elevation: 4,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  FontAwesomeIcons.plus,
                  color: Colors.white,
                ),
                SizedBox(width: 8),
                Text(
                  Strings.deposit,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
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
          addVerticalSpace(20.h),
          Padding(
            padding: EdgeInsets.only(bottom: 30.0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: Dimensions.defaultPaddingSize * 0.3),
              child: Center(
                child: Text(
                  Strings.transactionsHistory,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey, // Blanc en haut
                    Colors.green.shade900, // Vert foncé en bas
                  ],
                ),
                borderRadius: BorderRadius.circular(5.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
            ),
          ),
          addVerticalSpace(5.h),
          _transactionHistoryListWidget(context, signalements),
        ],
      ),
    );
  }

  Widget _transactionHistoryListWidget(
      BuildContext context, List<dynamic> signalements) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      itemCount: signalements.length,
      itemBuilder: (BuildContext context, int index) {
        final signalement = signalements[index];
        final monSignal = signalement['id'];

        IconData iconData;
        Color iconColor;
        switch (signalement['etat']) {
          case 'SIGNALE':
            iconData = Icons.flag;
            iconColor = Colors.red;
            break;
          case 'EN COURS':
            iconData = Icons.hourglass_bottom;
            iconColor = Colors.orange;
            break;
          case 'ENLEVE':
            iconData = Icons.check;
            iconColor = Colors.green;
            break;
          default:
            iconData = Icons.info;
            iconColor = Colors.black;

        }
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/depositMoneyDetailsScreen',
              arguments: signalement['signalementId'],
            );
          },
          child: SizedBox(
            height: 120,
            child: Padding(
              padding: EdgeInsets.all(Dimensions.defaultPaddingSize * 0.3),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      child: signalement['image_url'] != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.network(
                          signalement['image_url'],
                          fit: BoxFit.cover,
                        ),
                      )
                          : Container(),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                signalement['titre'] ?? '',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              signalement['commune'] ?? '',
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: Colors.grey[600],
                                  size: 16,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  signalement['formatted_date'] ?? '',
                                  style: TextStyle(
                                    color: Colors.blueGrey,
                                    fontSize: 14,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          iconData,
                          color: iconColor,
                        ),
                        SizedBox(height: 5),
                        Text(
                          signalement['etat'] == 'SIGNALE' ? 'Signalé' :
                          signalement['etat'] == 'EN COURS' ? 'En cours' : 'Résolu',
                          style: TextStyle(
                            color: iconColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 5),
                    Text(
                      signalement['created_date'] ?? '',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, int value) {
    Color textColor;

    switch(label) {
      case 'Total':
        textColor = Colors.black;
        break;
      case 'Résolus':
        textColor = Colors.green;
        break;
      case 'En Cours':
        textColor = Colors.orange;
        break;
      case 'Signalés':
        textColor = Colors.red;
        break;
      default:
        textColor = Colors.white;
    }

    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 18, color: textColor),
        ),
        Text(
          value.toString(),
          style: TextStyle(fontSize: 24, color: textColor, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

