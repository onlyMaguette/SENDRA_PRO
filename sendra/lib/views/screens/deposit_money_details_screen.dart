import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:walletium/controller/deposit_controller.dart';
import 'package:walletium/controller/deposit_money_details_controller.dart';
import 'package:walletium/utils/strings.dart';

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
                builder: (context) => DamagesForm(),
              ));
            } else if (title == 'Approbation') {
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

class BasicInfoForm extends StatelessWidget {
  final Map<String, dynamic> signalementData;

  BasicInfoForm({required this.signalementData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Informations de base',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: ListView(
          children: [
            _buildImageContainer(signalementData['image_url'], context),
            _buildReadOnlyField('Titre', signalementData['titre']),
            _buildReadOnlyField('Commune', signalementData['commune']),
            _buildReadOnlyField('Date et heure du signalement', signalementData['formatted_date']),
            //    _buildReadOnlyField('Nom Auteur', signalementData['nomAuteur']),
            //    _buildReadOnlyField('Prenom Auteur', signalementData['prenomAuteur']),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: TextFormField(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        readOnly: true,
      ),
    );
  }

  Widget _buildImageContainer(String imageUrl, BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => Dialog(
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Image.network(imageUrl),
            ),
          ),
        );
      },
      child: Container(
        width: 250,
        height: 250,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imageUrl,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}



class VehicleForm extends StatefulWidget {
  @override
  _VehicleFormState createState() => _VehicleFormState();
}

class _VehicleFormState extends State<VehicleForm> {
  final _formKey = GlobalKey<FormState>(); // Key for the form
  String? _etatGeneral;
  String? _paysEtranger;
  Map<String, bool> _details = {
    'Défaut de contrôle technique': false,
    'Véhicule immergé au dessus du tableau de bord': false,
    'Véhicule définitivement non identifiable': false,
    'Coque ou Chassis ni réparable ni remplaçable': false,
    'Pneumatiques manquantes': false,
    'Défauts techniques irréversibles et non remplaçables': false,
    'Véhicule complètement brûlé': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Véhicule',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildField('Numéro du véhicule', 'Ce champ est obligatoire'),
              _buildField('Marque', 'Ce champ est obligatoire'),
              _buildField('Type', 'Ce champ est obligatoire'),
              _buildField('Modèle', 'Ce champ est obligatoire'),
              _buildField('Catégorie du véhicule', 'Ce champ est obligatoire'),
              _buildField('Couleur', 'Ce champ est obligatoire'),
              SizedBox(height: 20),
              Text('État général :', style: TextStyle(fontSize: 16)),
              _buildRadioGroup(
                'État général',
                ['BON', 'MOYEN', 'DEGRADE'],
                _etatGeneral,
                    (value) {
                  setState(() {
                    _etatGeneral = value;
                  });
                },
              ),
              SizedBox(height: 20),
              Text('Pays étranger :', style: TextStyle(fontSize: 16)),
              _buildRadioGroup(
                'Pays étranger',
                ['OUI', 'NON'],
                _paysEtranger,
                    (value) {
                  setState(() {
                    _paysEtranger = value;
                  });
                },
              ),
              SizedBox(height: 20),
              Text('Détails :', style: TextStyle(fontSize: 16)),
              ..._details.keys.map((detail) {
                return CheckboxListTile(
                  title: Text(detail),
                  value: _details[detail],
                  onChanged: (value) {
                    setState(() {
                      _details[detail] = value ?? false;
                    });
                  },
                  activeColor: Colors.green, // Color when selected
                );
              }).toList(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Action à réaliser lors de l'appui sur le bouton Enregistrer
                  }
                },
                child: Text('Enregistrer'),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, String errorMessage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0), // Rounded corners
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0), // Rounded corners
            borderSide: BorderSide(color: Colors.grey, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0), // Rounded corners
            borderSide: BorderSide(color: Colors.deepPurple, width: 2.0),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return errorMessage; // Error message
          }
          return null; // Validation successful
        },
      ),
    );
  }

  Widget _buildRadioGroup(String label, List<String> options, String? groupValue, Function(String?) onChanged) {
    return FormField<String>(
      validator: (value) {
        if (groupValue == null) {
          return 'Ce champ est obligatoire'; // Error message when no option is selected
        }
        return null; // Validation successful
      },
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: options.map((option) {
                return Expanded(
                  child: RadioListTile<String>(
                    title: Text(option),
                    value: option,
                    groupValue: groupValue,
                    onChanged: (value) {
                      onChanged(value);
                      state.didChange(value); // Update validation state
                    },
                    activeColor: Colors.green, // Color when selected
                  ),
                );
              }).toList(),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  state.errorText!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        );
      },
    );
  }
}


class InfractionForm extends StatefulWidget {
  @override
  _InfractionFormState createState() => _InfractionFormState();
}

class _InfractionFormState extends State<InfractionForm> {
  final _formKey = GlobalKey<FormState>(); // Clé pour le formulaire
  bool _isSubmitting = false; // Variable pour suivre l'état de la soumission

  String? _lieu; // Variable pour stocker la sélection du lieu
  String? _meteo; // Variable pour stocker la sélection de la météo
  String? _adresse; // Variable pour stocker l'adresse
  String? _motif; // Variable pour stocker le motif

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Infraction',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildField('Adresse précise', (value) {
                if (value == null || value.isEmpty) {
                  return _isSubmitting ? 'Ce champ est obligatoire' : null;
                }
                _adresse = value;
                return null;
              }),
              _buildField('Motif de l\'infraction', (value) {
                if (value == null || value.isEmpty) {
                  return _isSubmitting ? 'Ce champ est obligatoire' : null;
                }
                _motif = value;
                return null;
              }),

              SizedBox(height: 20),
              Text('Lieu :', style: TextStyle(fontSize: 16)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text('PUBLIC'),
                      value: 'PUBLIC',
                      groupValue: _lieu,
                      onChanged: (value) {
                        setState(() {
                          _lieu = value;
                        });
                      },
                      activeColor: Colors.green, // Color when selected
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text('PRIVE'),
                      value: 'PRIVE',
                      groupValue: _lieu,
                      onChanged: (value) {
                        setState(() {
                          _lieu = value;
                        });
                      },
                      activeColor: Colors.green, // Color when selected
                    ),
                  ),
                ],
              ),
              if (_isSubmitting && _lieu == null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Ce champ est obligatoire',
                    style: TextStyle(color: Colors.red),
                  ),
                ),

              SizedBox(height: 20),
              Text('Météo :', style: TextStyle(fontSize: 16)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text('Nuit'),
                      value: 'Nuit',
                      groupValue: _meteo,
                      onChanged: (value) {
                        setState(() {
                          _meteo = value;
                        });
                      },
                      activeColor: Colors.green, // Color when selected
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text('Pluie'),
                      value: 'Pluie',
                      groupValue: _meteo,
                      onChanged: (value) {
                        setState(() {
                          _meteo = value;
                        });
                      },
                      activeColor: Colors.green, // Color when selected
                    ),
                  ),
                ],
              ),
              if (_isSubmitting && _meteo == null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Ce champ est obligatoire',
                    style: TextStyle(color: Colors.red),
                  ),
                ),

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isSubmitting = true; // Marquer comme étant en soumission
                  });
                  if (_formKey.currentState!.validate() && _lieu != null && _meteo != null) {
                    // Action à réaliser lors de l'appui sur le bouton Enregistrer
                    // Par exemple, vous pouvez soumettre les données ou les enregistrer
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Formulaire soumis')),
                    );
                  } else {
                    // Affiche un message d'erreur global si les conditions ne sont pas remplies
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Veuillez remplir tous les champs')),
                    );
                  }
                },
                child: Text('Enregistrer'),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, FormFieldValidator<String> validator) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        validator: validator,
      ),
    );
  }
}




class DamagesForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dommages',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: ListView(
          children: [
            // Ajouter ici les champs pour le formulaire des Dommages
            _buildField('Description des dommages'),
            _buildField('Coût estimé'),
            _buildField('Parties endommagées'),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
    );
  }
}

class ApprovalForm extends StatefulWidget {
  @override
  _ApprovalFormState createState() => _ApprovalFormState();
}

class _ApprovalFormState extends State<ApprovalForm> {
  final _formKey = GlobalKey<FormState>(); // Key for the form
  bool _isSubmitting = false; // Variable to track if the form is being submitted

  String? _approbation; // Variable to store the approval selection
  String? _motifApprobation; // Variable to store the approval reason

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Approbation',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Form(
          key: _formKey, // Associate the key with the form
          child: ListView(
            children: [
              SizedBox(height: 20),
              Text('Approuver ?', style: TextStyle(fontSize: 16)),
              _buildApprovalRadios(),
              _buildField(
                'Motif d\'Approbation',
                    (value) {
                  if (value == null || value.isEmpty) {
                    return _isSubmitting ? 'Ce champ est obligatoire' : null;
                  }
                  return null; // Validation successful
                },
                    (value) => _motifApprobation = value ?? '', // Handle null value
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isSubmitting = true; // Mark as submitting
                  });
                  if (_formKey.currentState!.validate() && _approbation != null) {
                    _formKey.currentState!.save(); // Save the form fields
                    // Action to perform when pressing the Save button
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Formulaire soumis')),
                    );
                  } else {
                    // Show a global error message if validation fails
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Veuillez remplir tous les champs')),
                    );
                  }
                },
                child: Text('Enregistrer'),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildApprovalRadios() {
    return FormField<String>(
      validator: (value) {
        if (_approbation == null) {
          return _isSubmitting ? 'Ce champ est obligatoire' : null;
        }
        return null; // Validation successful
      },
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: Text('OUI'),
                    value: 'OUI',
                    groupValue: _approbation,
                    onChanged: (value) {
                      setState(() {
                        _approbation = value;
                        state.didChange(value); // Update validation state
                      });
                    },
                    activeColor: Colors.green, // Color when selected
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: Text('NON'),
                    value: 'NON',
                    groupValue: _approbation,
                    onChanged: (value) {
                      setState(() {
                        _approbation = value;
                        state.didChange(value); // Update validation state
                      });
                    },
                    activeColor: Colors.green, // Color when selected
                  ),
                ),
              ],
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  state.errorText!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildField(
      String label,
      FormFieldValidator<String>? validator,
      FormFieldSetter<String>? onSaved) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }
}


class RemovalForm extends StatefulWidget {
  @override
  _RemovalFormState createState() => _RemovalFormState();
}

class _RemovalFormState extends State<RemovalForm> {
  final _formKey = GlobalKey<FormState>(); // Clé pour le formulaire
  final TextEditingController _dateController = TextEditingController();
  bool _isSubmitting = false; // Variable pour suivre l'état de la soumission

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Enlèvement',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildField('Motif d\'enlèvement', (value) {
                if (value == null || value.isEmpty) {
                  return _isSubmitting ? 'Ce champ est obligatoire' : null;
                }
                return null;
              }),
              _buildDateField('Date de l\'enlèvement'),
              _buildField('Lieu de l\'enlèvement', (value) {
                if (value == null || value.isEmpty) {
                  return _isSubmitting ? 'Ce champ est obligatoire' : null;
                }
                return null;
              }),
              _buildField('Nom Responsable de MEF', (value) {
                if (value == null || value.isEmpty) {
                  return _isSubmitting ? 'Ce champ est obligatoire' : null;
                }
                return null;
              }),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isSubmitting = true; // Marquer comme étant en soumission
                  });
                  if (_formKey.currentState!.validate() && _dateController.text.isNotEmpty) {
                    // Action à réaliser lors de l'appui sur le bouton Enregistrer
                    // Par exemple, vous pouvez soumettre les données ou les enregistrer
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Formulaire soumis')),
                    );
                  } else {
                    // Affiche un message d'erreur global si les conditions ne sont pas remplies
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Veuillez remplir tous les champs')),
                    );
                  }
                },
                child: Text('Enregistrer'),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, FormFieldValidator<String>? validator) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDateField(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: TextFormField(
        controller: _dateController,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        keyboardType: TextInputType.datetime,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return _isSubmitting ? 'Ce champ est obligatoire' : null;
          }
          return null;
        },
        onTap: () async {
          FocusScope.of(context).requestFocus(FocusNode()); // Close the keyboard
          DateTime? selectedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
          );

          if (selectedDate != null) {
            String formattedDate = DateFormat('dd/MM/yyyy').format(selectedDate);
            setState(() {
              _dateController.text = formattedDate;
            });
          }
        },
      ),
    );
  }
}



