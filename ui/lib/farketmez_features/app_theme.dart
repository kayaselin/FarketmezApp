import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:farketmez/classes/colors.dart';

class ThemeNotifier with ChangeNotifier {
  ThemeData _themeData;

  ThemeNotifier(this._themeData);

  ThemeData getTheme() => _themeData;

  setTheme(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners(); // This is important. It notifies all the listeners about the change.
  }
}

class ThemeProviderWidget extends StatelessWidget {
  final Widget child;

  const ThemeProviderWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeNotifier(AppTheme.lightTheme),
      child: child,
    );
  }
}



class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      // Genel ayarlar
      brightness: Brightness.light,
      primaryColor: AppColors.appbarColor,
      scaffoldBackgroundColor: AppColors.backgroundColor,
      
      // AppBar tema ayarları
      appBarTheme: const AppBarTheme(
        color: AppColors.appbarColor,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20)
        
      ),
      
      // Buton tema ayarları
      buttonTheme: const ButtonThemeData(
        buttonColor: AppColors.buttonColor,
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColors.buttonTextColor, backgroundColor: AppColors.buttonColor, // Buton üzerindeki yazı rengi
        ),
      ),
      
      // Text tema ayarları
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.textColor),
        bodyMedium: TextStyle(color: AppColors.textColor),
      ),
    );
  }

  static ThemeData get darkTheme {
  return ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.appbarColor,
    scaffoldBackgroundColor: Colors.grey[900],
    
    appBarTheme: const AppBarTheme(
      color: AppColors.appbarColor,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    
    buttonTheme: const ButtonThemeData(
      buttonColor: Colors.grey,
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.yellow, backgroundColor: Colors.grey[800], // Buton arka planını biraz daha koyu bir griye ayarlayın
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    ),
    
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
    ),
    
  );
  
}


}

