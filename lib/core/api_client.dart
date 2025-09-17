import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;
  final String adminKey;

  ApiClient({
    this.baseUrl = 'http://localhost:3001/api',
    this.adminKey = 'admin_panel_mega_secret',
  });

  Map<String, String> _headers() => {
    'Content-Type': 'application/json',
    'X-ADMIN-KEY': adminKey,
  };

  Future<dynamic> get(String path, {Map<String, String>? query}) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    final r = await http.get(uri, headers: _headers());
    if (r.statusCode >= 400) throw Exception(r.body);
    return json.decode(r.body);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final r = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers(),
      body: json.encode(body),
    );
    if (r.statusCode >= 400) throw Exception(r.body);
    return json.decode(r.body);
  }

  Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final r = await http.put(
      Uri.parse('$baseUrl$path'),
      headers: _headers(),
      body: json.encode(body),
    );
    if (r.statusCode >= 400) throw Exception(r.body);
    return json.decode(r.body);
  }

  Future<void> delete(String path, {Map<String, String>? query}) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    final r = await http.delete(uri, headers: _headers());
    if (r.statusCode >= 400) throw Exception(r.body);
  }
}
