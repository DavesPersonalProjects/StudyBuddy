import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

// HTTPS Request Function / Error Handler
Future getData(String url, String apiKey) async {
  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        HttpHeaders.authorizationHeader: "Bearer $apiKey",
      },
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      return jsonResponse;
    } else {
      // Handle failed response by throwing an exception or returning an error message
      throw Exception('Failed ${response.statusCode}');
    }
  } catch (e) {
    // Handle log errors
    //print('Error: $e');
    return null;
  }
}