import 'package:photoediter/export.dart';

class AppTheme{
  Color lightPrimaryColor = Colors.white;
  Color lightSecondaryColor= Colors.black;
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.white),

    colorScheme: const ColorScheme.light().copyWith(
      primary: Colors.grey,
      secondary: Colors.black54,
      onPrimaryFixedVariant: Color.fromARGB(182, 255, 255, 255),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppTheme().lightSecondaryColor,
      foregroundColor: AppTheme().lightPrimaryColor,
    )
  );
}