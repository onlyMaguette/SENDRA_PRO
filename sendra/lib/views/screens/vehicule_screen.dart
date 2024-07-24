import 'package:flutter/material.dart';

class VehicleForm extends StatefulWidget {
  @override
  _VehicleFormState createState() => _VehicleFormState();
}

class _VehicleFormState extends State<VehicleForm> {
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
        title: Text('Véhicule',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: ListView(
          children: [
            _buildField('Numéro du véhicule'),
            _buildField('Marque'),
            _buildField('Type'),
            _buildField('Modèle'),
            _buildField('Catégorie du véhicule'),
            _buildField('Couleur'),
            SizedBox(height: 20),
            Text('État général :', style: TextStyle(fontSize: 16)),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: Text('BON'),
                    value: 'BON',
                    groupValue: _etatGeneral,
                    onChanged: (value) {
                      setState(() {
                        _etatGeneral = value;
                      });
                    },
                    activeColor: Colors.green, // Color when selected
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: Text('MOYEN'),
                    value: 'MOYEN',
                    groupValue: _etatGeneral,
                    onChanged: (value) {
                      setState(() {
                        _etatGeneral = value;
                      });
                    },
                    activeColor: Colors.green, // Color when selected
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: Text('DEGRADE'),
                    value: 'DEGRADE',
                    groupValue: _etatGeneral,
                    onChanged: (value) {
                      setState(() {
                        _etatGeneral = value;
                      });
                    },
                    activeColor: Colors.green, // Color when selected
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text('Pays étranger :', style: TextStyle(fontSize: 16)),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: Text('OUI'),
                    value: 'OUI',
                    groupValue: _paysEtranger,
                    onChanged: (value) {
                      setState(() {
                        _paysEtranger = value;
                      });
                    },
                    activeColor: Colors.green, // Color when selected
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: Text('NON'),
                    value: 'NON',
                    groupValue: _paysEtranger,
                    onChanged: (value) {
                      setState(() {
                        _paysEtranger = value;
                      });
                    },
                    activeColor: Colors.green, // Color when selected
                  ),
                ),
              ],
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
                // Action à réaliser lors de l'appui sur le bouton Enregistrer
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
    );
  }
}

Widget _buildField(String label) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0), // Coins arrondis
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0), // Coins arrondis
          borderSide: BorderSide(color: Colors.grey, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0), // Coins arrondis
          borderSide: BorderSide(color: Colors.deepPurple, width: 2.0),
        ),
      ),
    ),
  );
}