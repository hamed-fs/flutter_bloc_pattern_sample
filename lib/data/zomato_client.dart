import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import 'package:flutter_bloc_pattern_sample/data/location.dart';
import 'package:flutter_bloc_pattern_sample/data/restaurant.dart';

class ZomatoClient {
  final String _apiKey = '2541a12ed27c64820b3fd9906093ef0b';
  final String _host = 'developers.zomato.com';
  final String _contextRoot = 'api/v2.1';

  Future<List<Location>> fetchLocations(String query) async {
    final Map<dynamic, dynamic> results = await request(
      path: 'locations',
      parameters: {
        'query': query,
        'count': '10',
      },
    );

    final List<Map<dynamic, dynamic>> suggestions = results['location_suggestions'];

    return suggestions.map<Location>((json) => Location.fromJson(json)).toList(growable: false);
  }

  Future<List<Restaurant>> fetchRestaurants(Location location, String query) async {
    final Map<dynamic, dynamic> results = await request(
      path: 'search',
      parameters: {
        'entity_id': location.id.toString(),
        'entity_type': location.type,
        'q': query,
        'count': '10',
      },
    );

    final List<Restaurant> restaurants = results['restaurants'].map<Restaurant>((json) => Restaurant.fromJson(json['restaurant'])).toList(growable: false);

    return restaurants;
  }

  Future<Map> request({@required String path, Map<String, String> parameters}) async {
    final Uri uri = Uri.https(_host, '$_contextRoot/$path', parameters);
    final http.Response results = await http.get(uri, headers: _headers);
    final dynamic jsonObject = json.decode(results.body);

    return jsonObject;
  }

  Map<String, String> get _headers => {'Accept': 'application/json', 'user-key': _apiKey};
}
