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
          return MaterialApp(
            title: 'Generator szczęścia',
            theme: ThemeData(
              colorScheme: ColorScheme.light(
                primary: userData.favoriteColor,
                secondary: userData.favoriteColor,
                surface: Colors.white,
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