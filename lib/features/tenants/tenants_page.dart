import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'tenants_provider.dart';

class TenantsPage extends StatelessWidget {
  const TenantsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<TenantsProvider>(context);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search tenants',
                ),
                onChanged: (v) => prov.loadTenants(search: v),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                await prov.createTenant("Loja Nova");
              },
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: prov.tenants.length,
            itemBuilder: (_, i) {
              final t = prov.tenants[i];
              return ListTile(
                title: Text(t['name']),
                subtitle: Text("Token: ${t['token']}"),
                selected: prov.selectedTenantId == t['id'],
                onTap: () => prov.selectTenant(t['id']),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => prov.deleteTenant(t['id']),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
