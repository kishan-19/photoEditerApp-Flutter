
// import 'package:photoediter/screen/photoOpen/photo_open_Provider.dart';
//
//
// import 'package:provider/provider.dart';

import 'package:photoediter/export.dart';

void main() async {
  // It is used so that void main function
  // can be initiated after successfully
  // intialization of data
  WidgetsFlutterBinding.ensureInitialized();

  // To intialise the hive database
  await HiveService.init();

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
