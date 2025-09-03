import 'dart:convert';
import 'package:http/http.dart' as http;

class GeoInfo {
  final String ip;
  final String country;
  final String region;
  final String city;
  final double latitude;
  final double longitude;
  final String isp;

  GeoInfo({
    required this.ip,
    required this.country,
    required this.region,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.isp,
  });

  Map<String, dynamic> toJson() {
    return {
      'country': country,
      'region': region,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  String toString() {
    return "GeoInfo(ip: $ip, country: $country, region: $region, city: $city, lat: $latitude, lon: $longitude, isp: $isp)";
  }

  factory GeoInfo.fromJson(Map<String, dynamic> json) {
    return GeoInfo(
      ip: json['query'] ?? '',
      country: json['country'] ?? '',
      region: json['regionName'] ?? '',
      city: json['city'] ?? '',
      latitude: (json['lat'] ?? 0).toDouble(),
      longitude: (json['lon'] ?? 0).toDouble(),
      isp: json['isp'] ?? '',
    );
  }
}

class GeoLocationService {
  final http.Client client;

  GeoLocationService({http.Client? client}) : client = client ?? http.Client();

  Future<String> _getPublicIP() async {
    final res = await client.get(
      Uri.parse("https://api.ipify.org?format=json"),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data["ip"];
    } else {
      throw Exception("Falha ao obter IP público: ${res.statusCode}");
    }
  }

  Future<GeoInfo> getLocation() async {
    final ip = await _getPublicIP();
    final res = await client.get(Uri.parse("http://ip-api.com/json/$ip"));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data["status"] == "success") {
        return GeoInfo.fromJson(data);
      } else {
        throw Exception("Erro na API de geolocalização: ${data["message"]}");
      }
    } else {
      throw Exception("Falha ao obter geolocalização: ${res.statusCode}");
    }
  }
}
