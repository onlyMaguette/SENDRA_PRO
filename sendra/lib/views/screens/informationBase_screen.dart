import 'package:flutter/material.dart';

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