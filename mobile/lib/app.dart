import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wardrowbe_app/core/router/app_router.dart';
import 'package:wardrowbe_app/core/theme/app_theme.dart';

class WardrowbeApp extends StatelessWidget {
  const WardrowbeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Wardrowbe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Default to dark — fashion apps look better
      routerConfig: appRouter,
    );
  }
}
