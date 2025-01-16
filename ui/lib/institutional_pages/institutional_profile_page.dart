import 'package:flutter/material.dart';
import 'package:farketmez/farketmez_features/welcome_page.dart';
import '../src/data/repositories/institution_repository.dart';
import 'package:farketmez/classes/token.dart';
import 'package:farketmez/classes/institution.dart';

class InstitutionalProfilePage extends StatefulWidget {
  const InstitutionalProfilePage({Key? key}) : super(key: key);

  @override
  _InstitutionalProfilePageState createState() => _InstitutionalProfilePageState();
}

class _InstitutionalProfilePageState extends State<InstitutionalProfilePage> {
  Institution? institutionProfile;
  final InstitutionRepository _institutionRepository = InstitutionRepository();

  @override
  void initState() {
    super.initState();
    loadInstitutionProfile();
  }

  void loadInstitutionProfile() async {
    try {
      // Bu örnekte, Token.institutionId'nin kullanılabilir olduğunu varsayıyorum.
      // Gerçekte, bu ID'yi nasıl elde ettiğinize bağlı olarak burayı güncellemeniz gerekebilir.
      Institution instProfile = await _institutionRepository.getInstitutionProfile(Token.institutionId);
      setState(() {
        institutionProfile = instProfile;
      });
    } catch (e) {
      // Hata yönetimi
      print("Kurum profil verisi yüklenirken bir hata oluştu: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kurumsal Profilim'),
        centerTitle: true,
      ),
      body: institutionProfile == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.grey.shade800,
                    child: Icon(
                      Icons.business,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Kurum Adı: ${institutionProfile!.institutionName}',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Adres: ${institutionProfile!.addressText}',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    'Telefon Numarası: ${institutionProfile!.phoneNumber}',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    'E Posta: ${institutionProfile!.email}',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const WelcomePage()),
                        (Route<dynamic> route) => false,
                      );
                    },
                    child: Text('Çıkış Yap'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
