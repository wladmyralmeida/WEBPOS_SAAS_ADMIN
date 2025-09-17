import 'package:flutter/material.dart';
import '../../core/api_client.dart';

class UsersProvider with ChangeNotifier {
  final ApiClient api;
  List<Map<String, dynamic>> users = [];

  UsersProvider(this.api);

  Future<void> loadUsers(String tenantId, {String? search}) async {
    final data = await api.get(
      '/admin/users',
      query: {
        'tenantId': tenantId,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    users = List<Map<String, dynamic>>.from(data);
    notifyListeners();
  }

  Future<void> createUser(
    String tenantId,
    String name,
    String email,
    String password,
    String role,
  ) async {
    await api.post('/admin/users', {
      'tenantId': tenantId,
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    });
    await loadUsers(tenantId);
  }

  Future<void> deleteUser(String tenantId, String userId) async {
    await api.delete('/admin/users/$userId', query: {'tenantId': tenantId});
    users.removeWhere((u) => u['id'] == userId);
    notifyListeners();
  }
}
