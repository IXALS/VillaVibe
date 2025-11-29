import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final weatherServiceProvider = Provider((ref) => WeatherService());

class WeatherService {
  Future<Map<String, dynamic>> getWeather(double lat, double lng) async {
    try {
      final url = Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lng&current=temperature_2m,weather_code&timezone=auto');
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final current = data['current'];
        return {
          'temp': current['temperature_2m'].round(),
          'code': current['weather_code'],
        };
      }
      return {'temp': 28, 'code': 0}; // Default fallback
    } catch (e) {
      return {'temp': 28, 'code': 0}; // Default fallback
    }
  }

  String getWeatherIcon(int code) {
    if (code == 0) return '☀️'; // Clear sky
    if (code <= 3) return '⛅'; // Partly cloudy
    if (code <= 48) return '🌫️'; // Fog
    if (code <= 67) return '🌧️'; // Rain
    if (code <= 77) return '❄️'; // Snow
    if (code <= 82) return '🌦️'; // Rain showers
    if (code <= 99) return '⛈️'; // Thunderstorm
    return '☀️';
  }
  
  String getWeatherCondition(int code) {
    if (code == 0) return 'Sunny';
    if (code <= 3) return 'Cloudy';
    if (code <= 48) return 'Foggy';
    if (code <= 67) return 'Rainy';
    if (code <= 77) return 'Snowy';
    if (code <= 82) return 'Showers';
    if (code <= 99) return 'Stormy';
    return 'Sunny';
  }
}
