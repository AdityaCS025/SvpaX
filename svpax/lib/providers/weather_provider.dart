import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherInfo {
  final double temperature;
  final String condition;
  final double minTemp;
  final double maxTemp;
  final int humidity;
  final double windSpeed;
  final String iconCode;
  final String cityName;
  final String country;

  WeatherInfo({
    required this.temperature,
    required this.condition,
    required this.minTemp,
    required this.maxTemp,
    required this.humidity,
    required this.windSpeed,
    required this.iconCode,
    required this.cityName,
    required this.country,
  });

  factory WeatherInfo.fromJson(Map<String, dynamic> json) {
    final weather = json['weather'][0];
    final main = json['main'];
    final wind = json['wind'];
    final sys = json['sys'];

    return WeatherInfo(
      temperature: (main['temp'] as num).toDouble(),
      condition: weather['main'] as String,
      minTemp: (main['temp_min'] as num).toDouble(),
      maxTemp: (main['temp_max'] as num).toDouble(),
      humidity: main['humidity'] as int,
      windSpeed: (wind['speed'] as num).toDouble(),
      iconCode: weather['icon'] as String,
      cityName: json['name'] as String,
      country: sys['country'] as String,
    );
  }
}

class CityWeatherInfo {
  final String city;
  final WeatherInfo? data;
  final String? error;

  CityWeatherInfo({required this.city, this.data, this.error});

  factory CityWeatherInfo.fromJson(Map<String, dynamic> json) {
    return CityWeatherInfo(
      city: json['city'] as String,
      data: json['data'] != null ? WeatherInfo.fromJson(json['data']) : null,
      error: json['error'] as String?,
    );
  }
}

class ForecastInfo {
  final DateTime dateTime;
  final double temperature;
  final String condition;
  final String iconCode;

  ForecastInfo({
    required this.dateTime,
    required this.temperature,
    required this.condition,
    required this.iconCode,
  });

  factory ForecastInfo.fromJson(Map<String, dynamic> json) {
    final weather = json['weather'][0];
    final main = json['main'];

    return ForecastInfo(
      dateTime: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      temperature: (main['temp'] as num).toDouble(),
      condition: weather['main'] as String,
      iconCode: weather['icon'] as String,
    );
  }
}

class WeatherProvider with ChangeNotifier {
  final String _baseUrl = 'http://localhost:5001';
  WeatherInfo? _currentWeather;
  List<CityWeatherInfo> _multipleCities = [];
  List<ForecastInfo> _forecast = [];
  bool _isLoading = false;
  String? _error;
  String _selectedCity = 'Mumbai';

  WeatherInfo? get currentWeather => _currentWeather;
  List<CityWeatherInfo> get multipleCities => _multipleCities;
  List<ForecastInfo> get forecast => _forecast;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCity => _selectedCity;

  void setSelectedCity(String city) {
    _selectedCity = city;
    notifyListeners();
  }

  Future<void> fetchWeather({String? city, String? country}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final cityParam = city ?? _selectedCity;
      String url = '$_baseUrl/weather?city=$cityParam';
      if (country != null && country.isNotEmpty) {
        url += '&country=$country';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _currentWeather = WeatherInfo.fromJson(data);
      } else {
        throw Exception('Failed to fetch weather data: ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
      _currentWeather = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMultipleCities({List<String>? cities}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      String url = '$_baseUrl/weather/multiple';
      if (cities != null && cities.isNotEmpty) {
        url += '?cities=${cities.join(',')}';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _multipleCities = data
            .map((item) => CityWeatherInfo.fromJson(item))
            .toList();
      } else {
        throw Exception(
          'Failed to fetch multiple cities weather: ${response.statusCode}',
        );
      }
    } catch (e) {
      _error = e.toString();
      _multipleCities = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchForecast({String? city, String? country}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final cityParam = city ?? _selectedCity;
      String url = '$_baseUrl/weather/forecast?city=$cityParam';
      if (country != null && country.isNotEmpty) {
        url += '&country=$country';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> forecastList = data['list'];
        _forecast = forecastList
            .map((item) => ForecastInfo.fromJson(item))
            .toList();
      } else {
        throw Exception(
          'Failed to fetch forecast data: ${response.statusCode}',
        );
      }
    } catch (e) {
      _error = e.toString();
      _forecast = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> searchCities(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/weather/search?q=$query'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to search cities: ${response.statusCode}');
      }
    } catch (e) {
      return [];
    }
  }

  Future<void> fetchWeatherByCoordinates(double lat, double lon) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await http.get(
        Uri.parse('$_baseUrl/weather/coordinates?lat=$lat&lon=$lon'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _currentWeather = WeatherInfo.fromJson(data);
      } else {
        throw Exception(
          'Failed to fetch weather by coordinates: ${response.statusCode}',
        );
      }
    } catch (e) {
      _error = e.toString();
      _currentWeather = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
