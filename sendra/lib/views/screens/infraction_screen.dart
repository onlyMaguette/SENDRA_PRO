import 'package:flutter/material.dart';

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