import 'package:flutter/material.dart';
import '../../core/api_client.dart';

Future<Map<String, dynamic>?> showUserDialog(
  BuildContext context,
  ApiClient api,
  String tenantId, {
  Map<String, dynamic>? existing,
}) async {
  final name = TextEditingController(text: existing?['name']);
  final email = TextEditingController(text: existing?['email']);
  final pass = TextEditingController();
  String role = existing?['role'] ?? 'employee';

  return showDialog<Map<String, dynamic>>(
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
                DropdownMenuItem(value: 'lojista', child: Text('Lojista')),
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
              final result = existing == null
                  ? await api.post('/admin/users', {
                      'tenantId': tenantId,
                      'name': name.text.trim(),
                      'email': email.text.trim(),
                      'password': pass.text.isEmpty
                          ? 'changeme123'
                          : pass.text.trim(),
                      'role': role,
                    })
                  : await api.put('/admin/users/${existing['id']}', {
                      'tenantId': tenantId,
                      'name': name.text.trim().isEmpty
                          ? null
                          : name.text.trim(),
                      'role': role,
                      'password': pass.text.isEmpty ? null : pass.text.trim(),
                    });
              if (context.mounted) Navigator.pop(context, result);
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}
