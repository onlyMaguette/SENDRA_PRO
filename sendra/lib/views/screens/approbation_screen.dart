
import 'package:flutter/material.dart';

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