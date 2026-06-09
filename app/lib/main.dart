import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_config.dart';
import 'app_colors.dart';
import 'classes.dart';
import 'functions.dart';
import 'router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (hasSupabaseConfig) {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabasePublishableKey,
    );
  }

  runApp(const WardrobeApp());
}

class WardrobeApp extends StatelessWidget {
  const WardrobeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Wardrobe App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme:
            ColorScheme.fromSeed(
              seedColor: AppColors.appTerracotta,
              brightness: Brightness.light,
            ).copyWith(
              primary: AppColors.appTerracotta,
              onPrimary: Colors.white,
              primaryContainer: AppColors.appWarmCream,
              onPrimaryContainer: AppColors.appEspresso,
              secondary: AppColors.appOlive,
              secondaryContainer: AppColors.appPeach,
              surface: AppColors.appCard,
              onSurface: AppColors.appEspresso,
            ),
        scaffoldBackgroundColor: AppColors.appCream,
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.appCard,
          indicatorColor: AppColors.appWarmCream,
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => TextStyle(
              color: states.contains(WidgetState.selected)
                  ? AppColors.appEspresso
                  : AppColors.appEspresso.withAlpha(150),
              fontSize: 12,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w800
                  : FontWeight.w600,
            ),
          ),
          iconTheme: WidgetStateProperty.resolveWith(
            (states) => IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? AppColors.appTerracotta
                  : AppColors.appEspresso.withAlpha(150),
            ),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.appCard,
          selectedColor: AppColors.appWarmCream,
          disabledColor: AppColors.appCard,
          labelStyle: const TextStyle(
            color: AppColors.appEspresso,
            fontWeight: FontWeight.w700,
          ),
          side: const BorderSide(color: Color(0xFFF0DEC6)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: AppColors.appTerracotta),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            foregroundColor: AppColors.appTerracotta,
            backgroundColor: AppColors.appWarmCream,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.appEspresso,
            foregroundColor: AppColors.appCard,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.appCard,
          prefixIconColor: AppColors.appTerracotta,
          suffixIconColor: AppColors.appTerracotta,
          hintStyle: TextStyle(color: AppColors.appEspresso.withAlpha(120)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFF0DEC6)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFF0DEC6)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: AppColors.appTerracotta,
              width: 1.4,
            ),
          ),
        ),
        textTheme: Typography.blackCupertino.apply(
          bodyColor: AppColors.appEspresso,
          displayColor: AppColors.appEspresso,
        ),
      ),
      routerConfig: appRouter,
    );
  }
}
