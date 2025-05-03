import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String _apiKey = 'fadeb0e1380f4c17ab8202036252604'; // <-- API KEY
  static const String _baseUrl = 'http://api.weatherapi.com/v1';

  static Future<List<Map<String, dynamic>>> fetchForecast(String cityName) async {
    final url = Uri.parse('$_baseUrl/forecast.json?key=$_apiKey&q=$cityName&days=3');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final forecastDays = data['forecast']['forecastday'];

        return List<Map<String, dynamic>>.from(forecastDays.map((day) => {
          'date': day['date'],
          'max_temp': day['day']['maxtemp_c'],
          'min_temp': day['day']['mintemp_c'],
          'condition': day['day']['condition']['text'],
        }));
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
    }
    return [];
  }
}
