import 'dart:async'; // Pour Completer
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Pour rootBundle
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DommagesScreen extends StatefulWidget {
  final int signalementId;

  DommagesScreen({required this.signalementId});

  @override
  _DommagesScreenState createState() => _DommagesScreenState();
}

class _DommagesScreenState extends State<DommagesScreen> {
  final List<Offset?> _points = [];
  Map<String, dynamic>? signalementDetails;
  ui.Image? _image;

  @override
  void initState() {
    super.initState();
    fetchSignalementDetails(widget.signalementId);
    _loadImage();
  }

  Future<void> fetchSignalementDetails(int signalementId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = 'http://votreapi.com/api/listerSignalement/$signalementId';
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
          setState(() {
            signalementDetails = dataList[0];
          });
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

  Future<void> _loadImage() async {
    final image = await loadImageFromAsset('assets/images/dommages.png');
    setState(() {
      _image = image;
    });
  }

  Future<ui.Image> loadImageFromAsset(String path) async {
    final ByteData data = await rootBundle.load(path);
    final Uint8List bytes = data.buffer.asUint8List();
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(bytes, (ui.Image image) {
      completer.complete(image);
    });
    return completer.future;
  }

  Future<void> _saveDrawing() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromPoints(Offset(0, 0), Offset(800, 600)));

    if (_image != null) {
      canvas.drawImage(_image!, Offset.zero, Paint());
    }

    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    for (int i = 0; i < _points.length - 1; i++) {
      if (_points[i] != null && _points[i + 1] != null) {
        canvas.drawLine(_points[i]!, _points[i + 1]!, paint);
      }
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(800, 600);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List imageBytes = byteData!.buffer.asUint8List();
    final String base64Image = base64Encode(imageBytes);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = 'http://votreapi.com/api/enregistrerDommages';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final body = jsonEncode({
      'signalementId': widget.signalementId,
      'image_url': base64Image,
    });

    final response = await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Dommages enregistrés avec succès')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Échec de l\'enregistrement des dommages')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dommages',
          style: TextStyle(color: Colors.green),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          if (signalementDetails != null) ...[
            Text('Détails du signalement :'),
            Text('ID : ${signalementDetails!['id']}'),
            // Ajoutez ici d'autres détails si nécessaire
          ],
          Expanded(
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  RenderBox renderBox = context.findRenderObject() as RenderBox;
                  _points.add(renderBox.globalToLocal(details.globalPosition));
                });
              },
              onPanEnd: (details) {
                _points.add(null);
              },
              child: CustomPaint(
                painter: DrawingPainter(_points, _image),
                child: Container(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () {
                    setState(() {
                      _points.clear();
                    });
                  },
                  icon: Icon(Icons.clear),
                  label: Text('Effacer'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () {
                    _saveDrawing();
                  },
                  icon: Icon(Icons.save),
                  label: Text('Enregistrer'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<Offset?> points;
  final ui.Image? image;

  DrawingPainter(this.points, this.image);

  @override
  void paint(Canvas canvas, Size size) {
    if (image != null) {
      canvas.drawImage(image!, Offset.zero, Paint());
    }

    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
