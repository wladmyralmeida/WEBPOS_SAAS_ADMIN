import 'dart:convert';
import 'package:http/http.dart' as http;

const String apiBase = String.fromEnvironment(
  'API_BASE',
  defaultValue: 'http://localhost:3001/api',
);
const String adminKey = String.fromEnvironment(
  'ADMIN_KEY',
  defaultValue: 'admin_panel_mega_secret',
);

class AdminTenantApi {
  final http.Client _c = http.Client();

  Map<String, String> _adminHeaders() => {
    'Content-Type': 'application/json',
    'X-ADMIN-KEY': adminKey,
  };

  Future<List<Map<String, dynamic>>> listTenants({String? search}) async {
    final uri = Uri.parse('$apiBase/tenants').replace(
      queryParameters: search?.isNotEmpty == true ? {'search': search!} : null,
    );
    final r = await _c.get(uri, headers: _adminHeaders());
    if (r.statusCode != 200) throw Exception(r.body);
    return List<Map<String, dynamic>>.from(json.decode(r.body));
  }

  Future<Map<String, dynamic>> createTenant(String name) async {
    final r = await _c.post(
      Uri.parse('$apiBase/tenants'),
      headers: _adminHeaders(),
      body: json.encode({'name': name}),
    );
    if (r.statusCode != 201) throw Exception(r.body);
    return json.decode(r.body);
  }

  Future<Map<String, dynamic>> updateTenant(
    String id, {
    String? name,
    bool regenerateToken = false,
  }) async {
    final r = await _c.put(
      Uri.parse('$apiBase/tenants/$id'),
      headers: _adminHeaders(),
      body: json.encode({'name': name, 'regenerateToken': regenerateToken}),
    );
    if (r.statusCode != 200) throw Exception(r.body);
    return json.decode(r.body);
  }

  Future<void> deleteTenant(String id) async {
    final r = await _c.delete(
      Uri.parse('$apiBase/tenants/$id'),
      headers: _adminHeaders(),
    );
    if (r.statusCode != 200) throw Exception(r.body);
  }

  // Admin manage users by tenantId (no JWT)
  Future<List<Map<String, dynamic>>> listUsers(
    String tenantId, {
    String? search,
  }) async {
    final uri = Uri.parse('$apiBase/admin/users').replace(
      queryParameters: {
        'tenantId': tenantId,
        if (search?.isNotEmpty == true) 'search': search!,
      },
    );
    final r = await _c.get(uri, headers: _adminHeaders());
    if (r.statusCode != 200) throw Exception(r.body);
    return List<Map<String, dynamic>>.from(json.decode(r.body));
  }

  Future<Map<String, dynamic>> createUser(
    String tenantId, {
    required String name,
    required String email,
    required String password,
    String role = 'employee',
  }) async {
    final r = await _c.post(
      Uri.parse('$apiBase/admin/users'),
      headers: _adminHeaders(),
      body: json.encode({
        'tenantId': tenantId,
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      }),
    );
    if (r.statusCode != 201) throw Exception(r.body);
    return json.decode(r.body);
  }

  Future<Map<String, dynamic>> updateUser(
    String tenantId,
    String userId, {
    String? name,
    String? role,
    String? password,
  }) async {
    final r = await _c.put(
      Uri.parse('$apiBase/admin/users/$userId'),
      headers: _adminHeaders(),
      body: json.encode({
        'tenantId': tenantId,
        'name': name,
        'role': role,
        'password': password,
      }),
    );
    if (r.statusCode != 200) throw Exception(r.body);
    return json.decode(r.body);
  }

  Future<void> deleteUser(String tenantId, String userId) async {
    final uri = Uri.parse(
      '$apiBase/admin/users/$userId',
    ).replace(queryParameters: {'tenantId': tenantId});
    final r = await _c.delete(uri, headers: _adminHeaders());
    if (r.statusCode != 200) throw Exception(r.body);
  }
}
