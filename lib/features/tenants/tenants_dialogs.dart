import 'package:flutter/material.dart';
import '../../core/api_client.dart';

Future<Map<String, dynamic>?> showTenantDialog(
  BuildContext context,
  ApiClient api, {
  Map<String, dynamic>? existing,
}) async {
  final controller = TextEditingController(text: existing?['name']);

  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: Text(existing == null ? 'Create tenant' : 'Edit tenant'),
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
              final result = existing == null
                  ? await api.post('/tenants', {'name': controller.text.trim()})
                  : await api.put('/tenants/${existing['id']}', {
                      'name': controller.text.trim(),
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
