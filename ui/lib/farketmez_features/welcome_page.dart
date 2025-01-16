import 'package:flutter/material.dart';
import 'package:farketmez/classes/colors.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      backgroundColor: AppColors.backgroundColor,


      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            // FARKETMEZ Text
            const Text(
              'FARKETMEZ',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor, // Adjust the color as needed
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30), // Spacing

            // Placeholder for logo
            Image.asset(
              'assets/logo.png',
              height: 250,
              width: 250,), // Replace with your logo widget later
            const SizedBox(height: 30), // Spacing

            

            // Personal Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonColor),
              child: const Text(
                'Personal',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.buttonTextColor,
                  ),
                ),
              onPressed: () {
                Navigator.pushNamed(context, '/personalLogin');
              },
            ),
            const SizedBox(height: 20), // Spacing

            // Institutional Button
             ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
                ),
              child: const Text(
                'Institutional',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.buttonTextColor,
                  ),
                ),
              onPressed: () {
                Navigator.pushNamed(context, '/institutionalLogin');
              },
            ),
          ],
        ),
      ),
    );
  }
}
