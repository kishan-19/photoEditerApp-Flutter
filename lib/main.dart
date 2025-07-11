import 'package:flutter/material.dart';
import 'package:photoediter/screen/home/home_Screen.dart';
import 'package:photoediter/screen/home/home_provider.dart';
import 'package:photoediter/screen/photoOpen/photo_open_Provider.dart';
import 'package:photoediter/style/app_theme.dart';
import 'package:provider/provider.dart';

void main() async {
  runApp( MultiProvider(providers: [
    ChangeNotifierProvider(
        create: (context)=>HomeProvider()),
    ChangeNotifierProvider(
        create: (context)=>PhotoOpenProvider()),
  ],child:const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Edite app',
      theme: AppTheme.lightTheme,
      home: HomeScreen(),
    );
  }
}
