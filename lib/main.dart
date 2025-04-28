import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(const GenderizerApp());
}

class GenderizerApp extends StatelessWidget {
  const GenderizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Genderizer App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const GenderizerScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GenderizerScreen extends StatefulWidget {
  const GenderizerScreen({super.key});

  @override
  _GenderizerScreenState createState() => _GenderizerScreenState();
}

class _GenderizerScreenState extends State<GenderizerScreen> {
  final TextEditingController _nameController = TextEditingController();
  String _result = '';
  Color _resultColor = Colors.grey;
  bool _isLoading = false;

  Future<void> _guessGender() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter a name",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _result = "Guessing...";
      _resultColor = Colors.grey;
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.genderize.io?name=${Uri.encodeComponent(name)}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _processResponse(data, name);
      } else {
        setState(() {
          _result = "Error fetching data. Please try again.";
          _resultColor = Colors.orange;
        });
      }
    } catch (e) {
      setState(() {
        _result = "Network error. Please check your connection.";
        _resultColor = Colors.red;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _processResponse(Map<String, dynamic> data, String name) {
    if (data['gender'] != null) {
      final probability = (data['probability'] * 100).round();
      if (data['gender'] == 'male') {
        setState(() {
          _result = "$name is most likely male ($probability% probability)";
          _resultColor = Colors.blue;
        });
      } else {
        setState(() {
          _result = "$name is most likely female ($probability% probability)";
          _resultColor = Colors.pink;
        });
      }
    } else {
      setState(() {
        _result = "Could not determine gender for $name";
        _resultColor = Colors.grey;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Genderizer App'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter a name to guess the gender:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter a name',
                hintText: 'e.g. John, Emma',
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _guessGender(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _guessGender,
              child:
                  _isLoading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : const Text('Guess Gender'),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: _resultColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _resultColor, width: 1),
              ),
              child: Text(
                _result,
                style: TextStyle(
                  fontSize: 18,
                  color: _resultColor,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
