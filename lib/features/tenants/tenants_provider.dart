import 'package:flutter/material.dart';
import '../../core/api_client.dart';

class TenantsProvider with ChangeNotifier {
  final ApiClient api;
  List<Map<String, dynamic>> tenants = [];
  String? selectedTenantId;

  TenantsProvider(this.api);

  Future<void> loadTenants({String? search}) async {
    final data = await api.get(
      '/tenants',
      query: search != null ? {'search': search} : null,
    );
    tenants = List<Map<String, dynamic>>.from(data);
    notifyListeners();
  }

  void selectTenant(String id) {
    selectedTenantId = id;
    notifyListeners();
  }

  Future<void> createTenant(String name) async {
    await api.post('/tenants', {'name': name});
    await loadTenants();
  }

  Future<void> deleteTenant(String id) async {
    await api.delete('/tenants/$id');
    tenants.removeWhere((t) => t['id'] == id);
    notifyListeners();
  }
}
