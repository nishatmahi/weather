import 'package:flutter/material.dart';
import 'package:weather/weather_service.dart';
import 'package:weather/ml_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String cityName = "Dhaka";
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> forecast = [];
  File? _image;
  String _prediction = "";

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    final data = await WeatherService.fetchForecast(cityName);
    setState(() {
      forecast = data;
    });
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final prediction = await MLService.predictWeather(pickedFile.path);
      setState(() {
        _image = File(pickedFile.path);
        _prediction = prediction;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE0B2),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Search Box
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter City Name',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          if (_controller.text.trim().isNotEmpty) {
                            setState(() {
                              cityName = _controller.text.trim();
                            });
                            fetchWeather();
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // City Name
                Center(
                  child: Text(
                    cityName,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 10),

                // Forecast Title
                const Center(
                  child: Text(
                    "3-Day Weather Forecast",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black54),
                  ),
                ),
                const SizedBox(height: 20),

                // 3 Days Forecast Short Cards
                if (forecast.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: forecast.map((day) {
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 5,
                        child: Container(
                          width: 100,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Column(
                            children: [
                              Text(
                                day['date'].substring(5), // MM-DD
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "${day['max_temp']}°C",
                                style: const TextStyle(fontSize: 16),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                child: Text(
                                  "${day['condition']}",
                                  style: const TextStyle(fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 30),

                // Upload Sky Image Section
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: pickImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text(
                          'Upload Sky Image for Prediction',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                if (_image != null)
                  Center(
                    child: Image.file(
                      _image!,
                      height: 200,
                    ),
                  ),

                if (_prediction.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Predicted Sky Condition: $_prediction',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
