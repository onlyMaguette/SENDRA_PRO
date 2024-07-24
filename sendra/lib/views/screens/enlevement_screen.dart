
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

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



