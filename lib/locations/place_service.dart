import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:yomate/locations/place_search.dart';

class PlaceSerive {
  final key = "AIzaSyAF2FpEl2tYHABFuUFKa5XDa5c2Q_1yj0k";

  Future<List<PlaceSearch>> getAutocomplete(String search) async {
    var url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$search&types=(cities)&key=$key';
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var jsonResults = json['predictions'] as List;
    return jsonResults.map((place) => PlaceSearch.fromJson(place)).toList();
  }
}
