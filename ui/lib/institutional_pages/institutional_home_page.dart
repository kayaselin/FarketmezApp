import 'package:flutter/material.dart';
import 'package:farketmez/classes/colors.dart';

class InstitutionalHomePage extends StatelessWidget {
  const InstitutionalHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appbarColor,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Image.asset('assets/logo.png', height: 50, width: 50,),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.pushNamed(context, '/institutionalProfilePage');
            },
          ),
        ],
      ),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(height: 15),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  minimumSize: const Size(double.infinity, 120),
                ),
                child: const Text(
                  'Kod AL',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/validateCodePage');
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  minimumSize: const Size(double.infinity, 120),
                ),
                child: const Text(
                  'FOTOGRAFLARIM',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/photoGallery');
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  minimumSize: const Size(double.infinity, 120),
                ),
                child: const Text(
                  'KAMPANYALARIM',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/institutionalDealsPage');
                },
              ),

              const SizedBox(height: 10),
              
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  minimumSize: const Size(double.infinity, 120),
                ),
                child: const Text(
                  'Istatistiklerim',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/institutionalStatisticsPage');
                },
              ),
            ],
          ),
          ),
          bottomNavigationBar: BottomAppBar(
        child: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            // Handle settings action
            Navigator.pushNamed(context, '/institutionalSettingsPage');
          },
        ),
      ),
    );
  }
}
