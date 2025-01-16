import 'package:flutter/material.dart';
import '../src/data/repositories/farketmez_repository.dart'; // Repo dosyanızı buraya import edin
import '../farketmez_features/farketmez_room_page.dart';
import 'package:farketmez/classes/token.dart';

class FarketmezJoinPage extends StatefulWidget {
  const FarketmezJoinPage({super.key});

  @override
  State<FarketmezJoinPage> createState() => _FarketmezJoinPageState();
}

class _FarketmezJoinPageState extends State<FarketmezJoinPage> {
  final TextEditingController _roomIdController = TextEditingController();
  final FarketmezRepository _repository = FarketmezRepository();// Repository'nizi burada oluşturun
  late bool isAdmin; 

  void _joinRoom(int roomId, int userId, bool isAdmin) async {
    var result = await _repository.joinRoom(roomId, userId);
    if (result['success']) {
      // Join işlemi başarılı, districtName ile birlikte oda sayfasına yönlendir
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FarketmezRoomPage(
            roomId: roomId,
            isAdmin: false,
            districtName: result[
                'districtName'], // districtName'i sayfaya parametre olarak geçirin
          ),
        ),
      );
    } else {
      // Join işlemi başarısız, kullanıcıya uyarı göster
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Odaya katılım başarısız.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Odaya Katıl'),
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
            const SizedBox(
              height: 200,
            ),
            TextField(
              controller: _roomIdController,
              decoration: const InputDecoration(
                labelText: 'ODA ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              child: const Text('Odaya Katıl'),
              onPressed: () {
                // Kullanıcıdan alınan oda ID'sini int'e çevir.
                int roomId = int.tryParse(_roomIdController.text) ?? 0;
                // _joinRoom fonksiyonunu çağırırken roomId ve userId'yi geçir.
                _joinRoom(roomId, Token.userId, isAdmin = false);
              },
            ),
            const SizedBox(height: 20),
            // Oda oluşturma butonu
            ElevatedButton(
              child: const Text('Oda Oluştur'),
              onPressed: () {
                Navigator.pushNamed(context,
                    '/farketmezCreatePage'); // Oda oluşturma sayfasına yönlendirme
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () => Navigator.pop(context),
            ),
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () => Navigator.pushNamed(
                  context, '/homePage'), // Anasayfaya yönlendirme
            ),
          ],
        ), // bottomNavigationBar kısmı aynı kalabilir
      ),
    );
  }
}
