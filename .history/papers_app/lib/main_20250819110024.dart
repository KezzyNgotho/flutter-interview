import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'src/app.dart';
import 'src/core/api_client.dart';
import 'src/core/auth_storage.dart';
import 'src/features/papers/data/papers_service.dart';
import 'src/features/papers/state/papers_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('cache');

  final authStorage = AuthStorage();
  final apiClient = ApiClient(authStorage: authStorage);
  final papersService = PapersService(
    apiClient: apiClient,
    authStorage: authStorage,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PapersProvider(service: papersService),
        ),
      ],
      child: const PapersApp(),
    ),
  );
}
