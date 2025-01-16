import '../personal_pages/personal_search_page.dart';
import 'package:flutter/material.dart';
import 'package:farketmez/classes/colors.dart';

class PersonalHomePage extends StatelessWidget {
  const PersonalHomePage({super.key});

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
              Navigator.pushNamed(context, '/personalProfilePage');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PersonalSearchPage())),
                    child: const AbsorbPointer(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Search',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  minimumSize: const Size(double.infinity, 120)),
              child: const Text(
                'FARKETMEZ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/farketmezJoinPage');
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  minimumSize: const Size(double.infinity, 120)),
              child: const Text(
                'kampanyalar',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                // Handle "kampanyalar" action
                Navigator.pushNamed(context, '/personalRandomCampaigns');
              
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
            Navigator.pushNamed(context, '/personalSettingsPage');
          },
        ),
      ),
    );
  }
}
