import 'package:flutter/material.dart';
import 'features/papers/ui/login_screen.dart';
import 'features/papers/ui/papers_list_screen.dart';
import 'features/papers/ui/paper_detail_screen.dart';

class PapersApp extends StatelessWidget {
  const PapersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Papers App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF154D71)),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          isDense: true,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          labelStyle: const TextStyle(fontWeight: FontWeight.w500),
          selectedColor: const Color(0xFF154D71),
          secondarySelectedColor: const Color(0xFF154D71),
        ),
        listTileTheme: const ListTileThemeData(dense: true),
      ),
      initialRoute: LoginScreen.routeName,
      routes: {
        LoginScreen.routeName: (_) => const LoginScreen(),
        PapersListScreen.routeName: (_) => const PapersListScreen(),
        PaperDetailScreen.routeName: (_) => const PaperDetailScreen(),
      },
    );
  }
}
