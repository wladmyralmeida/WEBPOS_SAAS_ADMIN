import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/api_client.dart';
import 'features/tenants/tenants_page.dart';
import 'features/users/users_page.dart';
import 'features/tenants/tenants_provider.dart';
import 'features/users/users_provider.dart';

void main() {
  final api = ApiClient();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TenantsProvider(api)),
        ChangeNotifierProvider(create: (_) => UsersProvider(api)),
      ],
      child: const AdminApp(),
    ),
  );
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SaaS POS Admin',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const AdminHomePage(),
    );
  }
}

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});
  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

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
    return Scaffold(
      appBar: AppBar(
        title: const Text("SaaS POS Admin"),
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: "Tenants"),
            Tab(text: "Users"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: const [TenantsPage(), UsersPage()],
      ),
    );
  }
}
