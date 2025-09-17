import 'package:flutter/material.dart';
import 'package:pos_admin_web/features/tenants/tenants_dialogs.dart';
import 'package:provider/provider.dart';
import '../../core/api_client.dart';
import '../../core/widgets/app_snackbar.dart';

class TenantsController extends StatefulWidget {
  const TenantsController({super.key});

  @override
  State<TenantsController> createState() => _TenantsControllerState();
}

class _TenantsControllerState extends State<TenantsController> {
  String _search = '';
  String? _selectedTenantId;
  List<Map<String, dynamic>> _tenants = [];
  bool _loading = false;
  String? _error;

  Future<void> _loadTenants() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = context.read<ApiClient>();
      final result = await api.get(
        '/tenants',
        query: _search.isNotEmpty ? {'search': _search} : null,
      );

      setState(() => _tenants = List<Map<String, dynamic>>.from(result));
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTenants();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search tenants',
                  ),
                  onChanged: (v) {
                    setState(() => _search = v);
                    _loadTenants();
                  },
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('New tenant'),
                onPressed: () async {
                  final created = await showTenantDialog(
                    context,
                    context.read<ApiClient>(),
                  );
                  if (created != null && mounted) {
                    AppSnackbar.show(
                      context,
                      'Tenant created: ${created['name']}',
                    );
                    _loadTenants();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator.adaptive())
                : _error != null
                ? Center(child: Text('Error: $_error'))
                : _tenants.isEmpty
                ? const Center(child: Text('No tenants'))
                : ListView.separated(
                    itemCount: _tenants.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (_, i) {
                      final t = _tenants[i];
                      return ListTile(
                        title: Text(t['name']),
                        subtitle: Text('token: ${t['token']}'),
                        selected: _selectedTenantId == t['id'],
                        onTap: () =>
                            setState(() => _selectedTenantId = t['id']),
                        trailing: Wrap(
                          spacing: 8,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.vpn_key),
                              tooltip: 'Regenerate token',
                              onPressed: () async {
                                final updated = await context
                                    .read<ApiClient>()
                                    .put('/tenants/${t['id']}', {
                                      'regenerateToken': true,
                                    });
                                if (mounted) {
                                  AppSnackbar.show(
                                    context,
                                    'New token: ${updated['token']}',
                                  );
                                  _loadTenants();
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                final updated = await showTenantDialog(
                                  context,
                                  context.read<ApiClient>(),
                                  existing: t,
                                );
                                if (updated != null && mounted) {
                                  AppSnackbar.show(
                                    context,
                                    'Tenant updated: ${updated['name']}',
                                  );
                                  _loadTenants();
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_forever,
                                color: Colors.red,
                              ),
                              onPressed: () async {
                                await context.read<ApiClient>().delete(
                                  '/tenants/${t['id']}',
                                );
                                if (mounted) {
                                  AppSnackbar.show(
                                    context,
                                    'Tenant deleted: ${t['name']}',
                                  );
                                  _loadTenants();
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
