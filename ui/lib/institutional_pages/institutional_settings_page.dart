import 'package:flutter/material.dart';
import '../farketmez_features/app_theme.dart';
import 'package:provider/provider.dart';

class InstitutionalSettingsPage extends StatelessWidget {
  const InstitutionalSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  minimumSize: const Size(double.infinity, 120)),
              child: const Text(
                'Profil Düzenle',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                // Handle "ne istiyorum?" action
                Navigator.pushNamed(context, '/institutionalUpdateProfilePage');
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
  style: ElevatedButton.styleFrom(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    minimumSize: const Size(double.infinity, 120), // Temaya göre arka plan rengi değişikliği
  ),
  child: const Text(
    'DARK MODE',
    style: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold, // Metin rengini daha görünür hale getirmek için değiştirildi
    ),
  ),
  onPressed: () {
    // Handle "dark mode" action
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    // Toggle the theme based on the current brightness
    if (themeNotifier.getTheme().brightness == Brightness.dark) {
      themeNotifier.setTheme(AppTheme.lightTheme);
    } else {
      themeNotifier.setTheme(AppTheme.darkTheme);
    }
  },
),
          ]),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            Expanded(
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () {
                  // Handle settings action
                  Navigator.pop(context);
                },
              ),
            ),
            Expanded(
              child: IconButton(
                icon: const Icon(Icons.home_filled),
                onPressed: () {
                  // Handle settings action
                  Navigator.pushNamed(context, '/institutionalHomePage');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
