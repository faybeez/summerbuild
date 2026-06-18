import 'package:flutter/material.dart';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherService {
  static Map<String, dynamic>? _cachedWeather;
  static DateTime? _lastFetched;

  static const _cacheDuration = Duration(minutes: 30);

  bool get _isCacheValid =>
      _cachedWeather != null &&
      _lastFetched != null &&
      DateTime.now().difference(_lastFetched!) < _cacheDuration;

  Future<Position?> getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );
  }

  /// find closest area
  String getNearestArea(double userLat, double userLon, List areas) {
    String nearest = areas[0]['name'];
    double minDist = double.infinity;

    for (var area in areas) {
      double lat = area['label_location']['latitude'];
      double lon = area['label_location']['longitude'];
      double dist = sqrt(pow(lat - userLat, 2) + pow(lon - userLon, 2));
      if (dist < minDist) {
        minDist = dist;
        nearest = area['name'];
      }
    }
    return nearest;
  }

  // fetch
  Future<Map<String, dynamic>> fetchWeather() async {
    debugPrint('Fetching weather data...');
    if (_isCacheValid) return _cachedWeather!;

    Position? pos = await getUserLocation();
    debugPrint('User location: $pos');
    if (pos == null) throw Exception('Location unavailable');

    debugPrint(
      'Fetching weather data for location: ${pos.latitude}, ${pos.longitude}',
    );

    final results = await Future.wait([
      http.get(
        Uri.parse(
          'https://api-open.data.gov.sg/v2/real-time/api/two-hr-forecast',
        ),
      ),
      http.get(
        Uri.parse(
          'https://api-open.data.gov.sg/v2/real-time/api/air-temperature',
        ),
      ),
      http.get(
        Uri.parse(
          'https://api-open.data.gov.sg/v2/real-time/api/relative-humidity',
        ),
      ),
    ]);
    debugPrint(
      'Weather API responses received: ${results.map((r) => r.statusCode)}',
    );

    // debugPrint('results[0].body: ${results[0].body}');
    // debugPrint('results[1].body: ${results[1].body}');
    // debugPrint('results[2].body: ${results[2].body}');

    final forecastJson = jsonDecode(results[0].body);
    final tempJson = jsonDecode(results[1].body);
    final humidJson = jsonDecode(results[2].body);

    // debugPrint('Weather API responses:');
    // debugPrint('Forecast: ${forecastJson['data']['items'][0]['forecasts']}');
    // debugPrint('Temperature: ${tempJson['data']['readings'][0]['data']}');
    // debugPrint('Humidity: ${humidJson['data']['readings'][0]['data']}');

    // match user to nearest NEA forecast area
    final areas = forecastJson['data']['area_metadata'];
    final nearestArea = getNearestArea(pos.latitude, pos.longitude, areas);

    final forecasts = forecastJson['data']['items'][0]['forecasts'] as List;
    final forecast = forecasts.firstWhere(
      (f) => f['area'] == nearestArea,
      orElse: () => {'forecast': 'N/A'},
    );

    // find nearest temperature station
    final tempStations = tempJson['data']['stations'] as List;
    final tempReadings = tempJson['data']['readings'][0]['data'] as List;
    final nearestTempStation = getNearestArea(
      pos.latitude,
      pos.longitude,
      tempStations
          .map((s) => {'name': s['id'], 'label_location': s['location']})
          .toList(),
    );
    final tempReading = tempReadings.firstWhere(
      (r) => r['stationId'] == nearestTempStation,
      orElse: () => {'value': null},
    );

    // find nearest humidity station
    final humidStations = humidJson['data']['stations'] as List;
    final humidReadings = humidJson['data']['readings'][0]['data'] as List;
    final nearestHumidStation = getNearestArea(
      pos.latitude,
      pos.longitude,
      humidStations
          .map((s) => {'name': s['id'], 'label_location': s['location']})
          .toList(),
    );
    final humidReading = humidReadings.firstWhere(
      (r) => r['stationId'] == nearestHumidStation,
      orElse: () => {'value': null},
    );

    // debugPrint(
    //   'Nearest Area: $nearestArea, Forecast: ${forecast['forecast']}, '
    //   'Temp Station: $nearestTempStation, Temp: ${tempReading['value']}, '
    //   'Humid Station: $nearestHumidStation, Humidity: ${humidReading['value']}',
    // );

    _cachedWeather = {
      'area': nearestArea, //string
      'forecast': forecast['forecast']
          .toString()
          .replaceAll(RegExp(r'\s*\((Day|Night)\)', caseSensitive: false), '')
          .trim(), //string
      'temperature': tempReading['value'] as double, //double
      'humidity': humidReading['value'] as double, //double
    };
    _lastFetched = DateTime.now();

    return _cachedWeather!;
  }
}
