import 'package:farketmez/classes/platform.dart';
import 'package:farketmez/institutional_pages/institutional_create_deal_page.dart';
import 'package:farketmez/institutional_pages/institutional_photos_page.dart';
import 'package:farketmez/institutional_pages/institutional_update_profile_page.dart';
import 'package:farketmez/institutional_pages/institutional_use_code.dart';
import 'package:farketmez/personal_pages/personal_display_campaigns.dart';
import 'package:farketmez/personal_pages/personal_update_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'farketmez_features/app_theme.dart'; // Import your app_theme.dart file
import 'farketmez_features/farketmez_create_page.dart';
import 'institutional_pages/institutional_deals_page.dart';
import 'institutional_pages/institutional_settings_page.dart';
import 'institutional_pages/institutional_statistics_page.dart';
import 'personal_pages/personal_settings_page.dart';
import 'farketmez_features/farketmez_join_page.dart';
import 'institutional_pages/institutional_profile_page.dart';
import 'personal_pages/personal_profile_page.dart';
import 'institutional_pages/institutional_home_page.dart';
import 'institutional_pages/institutional_register_page.dart';
import 'personal_pages/personal_home_page.dart';
import 'personal_pages/personal_register_page.dart';
import 'farketmez_features/welcome_page.dart';
import 'personal_pages/personal_login_page.dart'; // Import Personal Login Page
import 'institutional_pages/institutional_login_page.dart'; // Import Institutional Login Page
import 'classes/authentication.dart';


void main() async {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeNotifier(AppTheme.lightTheme)),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => PlatformProvider()),
      ],
      child: const FarketmezApp(),
    ),
  );
}



class FarketmezApp extends StatelessWidget {
  const FarketmezApp({super.key});


  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Farketmez',
      theme: themeNotifier.getTheme(), // Apply the theme from ThemeNotifier
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomePage(),
        '/personalLogin': (context) => const PersonalLoginPage(),
        '/institutionalLogin': (context) => const InstitutionalLoginPage(),
        '/personalRegister': (context) => const PersonalRegisterPage(),
        '/institutionalRegister':(context) => const InstitutionalRegisterScreen(),
        '/personalHomePage' :(context) => const PersonalHomePage(),
        '/institutionalHomePage' :(context) => const InstitutionalHomePage(),
        '/personalProfilePage' :(context) => const PersonalProfilePage(),
        '/institutionalProfilePage' :(context) => const InstitutionalProfilePage(),
        '/farketmezJoinPage' :(context) => const FarketmezJoinPage(),
        '/farketmezCreatePage' :(context) => const FarketmezCreatePage(),
        '/personalSettingsPage' :(context) => const PersonalSettingsPage(),
        '/institutionalStatisticsPage' :(context) => const InstitutionalStatisticsPage(),
        '/institutionalSettingsPage' :(context) => const InstitutionalSettingsPage(),
        '/institutionalDealsPage' :(context) => const InstitutionalDealsPage(),
        '/institutionalCreateDealPage' :(context) => const InstitutionalCreateDealPage(),
        '/personalUpdateProfilePage' :(context) => const PersonalUpdateProfilePage(),
        '/institutionalUpdateProfilePage' :(context) => const InstitutionalUpdateProfilePage(),
        '/photoGallery' :(context) => const PhotoGallery(),
        '/personalRandomCampaigns' :(context) => const PersonalDisplayDealsPage(),
        '/validateCodePage' :(context) => const ValidateCampaignPage(),
      },
    );
  }
}
