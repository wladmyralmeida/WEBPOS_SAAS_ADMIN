import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '/pages/tenants_users_page.dart';

void main() {
  runApp(const ProviderScope(child: AdminApp()));
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SaaS Admin',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const TenantsUsersPage(),
    );
  }
}
