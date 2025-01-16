import 'package:flutter/material.dart';
import 'package:farketmez/farketmez_features/welcome_page.dart';
import '../src/data/repositories/user_repository.dart';
import 'package:farketmez/classes/token.dart';
import 'package:farketmez/classes/user.dart';

class PersonalProfilePage extends StatefulWidget {
  const PersonalProfilePage({Key? key}) : super(key: key);

  @override
  _PersonalProfilePageState createState() => _PersonalProfilePageState();
}

class _PersonalProfilePageState extends State<PersonalProfilePage> {
  late Future<User> userProfile;
  final UserRepository _userRepository = UserRepository();

  @override
  void initState() {
    super.initState();
    userProfile = _userRepository.getUserProfile(Token.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PROFİLİM'),
        centerTitle: true,
      ),
      body: Center(
        child: FutureBuilder<User>(
          future: userProfile,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircleAvatar(
                      radius: 80, // Profil ikonunun boyutu
                      backgroundColor: Colors.grey.shade800,
                      child: Icon(
                        Icons.person,
                        size: 80, // İkonun boyutu
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20), // İkon ile metin arasındaki boşluk
                    Text(
                      'Kullanıcı Adı: ${snapshot.data!.username}',
                      style: const TextStyle(
                        fontSize: 24, // Metin boyutu
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'E Posta Adresi: ${snapshot.data!.email}',
                      style: const TextStyle(
                        fontSize: 20, // Metin boyutu
                      ),
                    ),
                    const SizedBox(height: 40), // Metin ile buton arasındaki boşluk
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const WelcomePage()),
                          (Route<dynamic> route) => false,
                        );
                      },
                      child: const Text('Çıkış Yap'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20), // Butonun padding'i
                      ),
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                return Text('Hata: ${snapshot.error}');
              }
            }
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
