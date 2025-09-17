import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '/api/api.dart';

final apiProvider = Provider((ref) => AdminTenantApi());
final tenantsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String?>((ref, search) {
      return ref.watch(apiProvider).listTenants(search: search);
    });

class TenantsUsersPage extends ConsumerStatefulWidget {
  const TenantsUsersPage({super.key});
  @override
  ConsumerState<TenantsUsersPage> createState() => _TenantsUsersPageState();
}

class _TenantsUsersPageState extends ConsumerState<TenantsUsersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  String _tenantSearch = '';
  String? _selectedTenantId;
  String _userSearch = '';

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tenantsAsync = ref.watch(tenantsProvider(_tenantSearch));
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('SaaS Admin'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Tenants'), Tab(text: 'Users')],
          ),
          automaticallyImplyLeading: false,
          primary: true,
          flexibleSpace: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TabBar(
                controller: _tab,
                tabs: const [Tab(text: 'Tenants'), Tab(text: 'Users')],
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tab,
          children: [
            // TENANTS TAB
            Padding(
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
                          onChanged: (v) => setState(() => _tenantSearch = v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('New tenant'),
                        onPressed: _newTenantDialog,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: tenantsAsync.when(
                      data:
                          (tenants) =>
                              tenants.isEmpty
                                  ? const Center(child: Text('No tenants'))
                                  : ListView.separated(
                                    itemCount: tenants.length,
                                    separatorBuilder:
                                        (_, __) => const Divider(),
                                    itemBuilder: (_, i) {
                                      final t = tenants[i];
                                      return ListTile(
                                        title: Text(t['name']),
                                        subtitle: Text('token: ${t['token']}'),
                                        selected: _selectedTenantId == t['id'],
                                        onTap:
                                            () => setState(
                                              () => _selectedTenantId = t['id'],
                                            ),
                                        trailing: Wrap(
                                          spacing: 8,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.vpn_key),
                                              tooltip: 'Regenerate token',
                                              onPressed: () async {
                                                final updated = await ref
                                                    .read(apiProvider)
                                                    .updateTenant(
                                                      t['id'],
                                                      regenerateToken: true,
                                                    );
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'New token: ${updated['token']}',
                                                    ),
                                                  ),
                                                );
                                                setState(() {});
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.edit),
                                              onPressed:
                                                  () => _editTenantDialog(t),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete_forever,
                                                color: Colors.red,
                                              ),
                                              onPressed: () async {
                                                await ref
                                                    .read(apiProvider)
                                                    .deleteTenant(t['id']);
                                                setState(() {});
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                      loading:
                          () =>
                              const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('Error: $e')),
                    ),
                  ),
                ],
              ),
            ),

            // USERS TAB
            Padding(
              padding: const EdgeInsets.all(16),
              child:
                  _selectedTenantId == null
                      ? const Center(
                        child: Text('Select a tenant on the TENANTS tab'),
                      )
                      : UsersPane(
                        tenantId: _selectedTenantId!,
                        search: _userSearch,
                        onSearch: (v) => setState(() => _userSearch = v),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _newTenantDialog() async {
    final controller = TextEditingController();
    final api = ref.read(apiProvider);
    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Create tenant'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (controller.text.trim().isEmpty) return;
                await api.createTenant(controller.text.trim());
                if (mounted) Navigator.pop(context);
                setState(() {});
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editTenantDialog(Map<String, dynamic> t) async {
    final controller = TextEditingController(text: t['name']);
    final api = ref.read(apiProvider);
    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Edit tenant'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                await api.updateTenant(t['id'], name: controller.text.trim());
                if (mounted) Navigator.pop(context);
                setState(() {});
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

class UsersPane extends ConsumerWidget {
  final String tenantId;
  final String search;
  final ValueChanged<String> onSearch;
  const UsersPane({
    super.key,
    required this.tenantId,
    required this.search,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search users',
                ),
                onChanged: onSearch,
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              icon: const Icon(Icons.person_add),
              label: const Text('New user'),
              onPressed: () => _userDialog(context, ref, tenantId),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: ref.read(apiProvider).listUsers(tenantId, search: search),
            builder: (c, s) {
              if (!s.hasData) {
                if (s.hasError) return Center(child: Text('Error: ${s.error}'));
                return const Center(child: CircularProgressIndicator());
              }
              final users = s.data!;
              if (users.isEmpty) return const Center(child: Text('No users'));
              return ListView.separated(
                itemCount: users.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (_, i) {
                  final u = users[i];
                  return ListTile(
                    title: Text(u['name']),
                    subtitle: Text('${u['email']} • ${u['role']}'),
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed:
                              () => _userDialog(
                                context,
                                ref,
                                tenantId,
                                existing: u,
                              ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await ref
                                .read(apiProvider)
                                .deleteUser(tenantId, u['id']);
                            (context as Element).markNeedsBuild();
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _userDialog(
    BuildContext context,
    WidgetRef ref,
    String tenantId, {
    Map<String, dynamic>? existing,
  }) async {
    final name = TextEditingController(text: existing?['name']);
    final email = TextEditingController(text: existing?['email']);
    final pass = TextEditingController();
    String role = existing?['role'] ?? 'employee';

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(existing == null ? 'Create user' : 'Edit user'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: email,
                decoration: const InputDecoration(labelText: 'Email'),
                enabled: existing == null,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: role,
                items: const [
                  DropdownMenuItem(value: 'employee', child: Text('Employee')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
                onChanged: (v) => role = v!,
                decoration: const InputDecoration(labelText: 'Role'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: pass,
                decoration: const InputDecoration(
                  labelText: 'Password (leave blank to keep)',
                ),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (existing == null) {
                  await ref
                      .read(apiProvider)
                      .createUser(
                        tenantId,
                        name: name.text.trim(),
                        email: email.text.trim(),
                        password: pass.text.isEmpty ? 'changeme123' : pass.text,
                        role: role,
                      );
                } else {
                  await ref
                      .read(apiProvider)
                      .updateUser(
                        tenantId,
                        existing['id'],
                        name:
                            name.text.trim().isEmpty ? null : name.text.trim(),
                        role: role,
                        password: pass.text.isEmpty ? null : pass.text,
                      );
                }
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
