import 'dart:convert';
import 'package:http/http.dart' as http;

class MesonetService {
  final String _apiKey = 'YOUR_API_TOKEN'; // Replace with actual token
  final String _baseUrl = 'https://api.mesonet.org/api/v1/stations';

  Future<Map<String, dynamic>?> fetchEvapData(String stationId) async {
    final url = '$_baseUrl/$stationId/observations/latest?token=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        print('❌ Error: ${response.statusCode} - ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      print('❌ Exception occurred: $e');
      return null;
    }
  }
}