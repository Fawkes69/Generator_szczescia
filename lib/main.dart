import 'package:flutter/material.dart';
import 'package:generator/home.dart';
import 'package:provider/provider.dart';
import 'models/user_data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserData(),
      child: Consumer<UserData>(
        builder: (context, userData, child) {
          final luminance = userData.favoriteColor.computeLuminance();
          final isLightColor = luminance > 0.5;
          return MaterialApp(
            title: 'Generator szczęścia',
            theme: ThemeData(
              colorScheme: ColorScheme.light(
                primary: userData.favoriteColor,
                secondary: userData.favoriteColor,
                surface: isLightColor ? userData.favoriteColor : userData.invertedColor,
              ),
              useMaterial3: true,
            ),
            home: const HomePage(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}