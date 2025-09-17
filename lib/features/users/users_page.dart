import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../tenants/tenants_provider.dart';
import 'users_provider.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tenantsProv = Provider.of<TenantsProvider>(context);
    final usersProv = Provider.of<UsersProvider>(context);

    if (tenantsProv.selectedTenantId == null) {
      return const Center(child: Text("Selecione um tenant primeiro"));
    }

    return Column(
      children: [
        ElevatedButton(
          onPressed: () => usersProv.loadUsers(tenantsProv.selectedTenantId!),
          child: const Text("Carregar usuários"),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: usersProv.users.length,
            itemBuilder: (_, i) {
              final u = usersProv.users[i];
              return ListTile(
                title: Text(u['name']),
                subtitle: Text("${u['email']} • ${u['role']}"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => usersProv.deleteUser(
                    tenantsProv.selectedTenantId!,
                    u['id'],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
