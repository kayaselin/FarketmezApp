import 'package:flutter/material.dart';
import '../src/data/repositories/farketmez_repository.dart'; // Doğru yolu sağladığınızdan emin olun
import '../src/data/repositories/location_tags_repository.dart';
import '../classes/location_tag.dart';
import 'package:farketmez/classes/token.dart';
import '../farketmez_features/farketmez_room_page.dart'; // RoomPage sayfasının import edildiğinden emin olun

class FarketmezCreatePage extends StatefulWidget {
  const FarketmezCreatePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FarketmezCreatePageState createState() => _FarketmezCreatePageState();
}

class _FarketmezCreatePageState extends State<FarketmezCreatePage> {
  final TextEditingController _maxParticipantsController = TextEditingController();
  final LocationTagsRepository _locationTagsRepository = LocationTagsRepository();
  List<LocTag> _locationTags = [];
  LocTag? _selectedLocationTag;
  final FarketmezRepository _farketmezRepository = FarketmezRepository(); // Repository'nizin adını kontrol edin
  late bool isAdmin;

  @override
  void initState() {
    super.initState();
    _fetchLocationTags();
  }

  Future<void> _fetchLocationTags() async {
    try {
      var locationTags = await _locationTagsRepository.getLocationTags();
      setState(() {
        _locationTags = locationTags;
      });
    } catch (e) {
      print('Lokasyon tag listesi çekilirken bir hata oluştu: $e');
    }
  }

  Future<void> _createRoom() async {
  if (_selectedLocationTag != null && _maxParticipantsController.text.isNotEmpty) {
    int maxParticipants = int.tryParse(_maxParticipantsController.text) ?? 0;
    int? roomId = await _farketmezRepository.createRoom(
      Token.userId, // 'Token.userId' kullanıcı ID'si.
      maxParticipants,
      _selectedLocationTag!.locTagId,
      isAdmin = true
      
    );

    if (roomId != null) {
      // Oda başarıyla oluşturulduğunda, RoomPage'e yönlendir.
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
    builder: (context) => FarketmezRoomPage(
      roomId: roomId, // önceki sayfadan alınan ya da yeni oluşturulan oda ID'si
      locationTagId: _selectedLocationTag!.locTagId, // seçilen lokasyon tag ID'si
      districtName: _selectedLocationTag!.districtName, // seçilen lokasyonun adı
      isAdmin: true,
    ),
      ),
      );
    } else {
      // Hata mesajı göster.
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Hata'),
          content: const Text('Oda oluşturulamadı. Lütfen tekrar deneyin.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Tamam'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }
}

  void _showLocationTagSelectionDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Lokasyon Tag Seçimi"),
          content: SingleChildScrollView(
            child: ListBody(
              children: _locationTags.map((locTag) {
                return RadioListTile<LocTag>(
                  title: Text(locTag.districtName),
                  value: locTag,
                  groupValue: _selectedLocationTag,
                  onChanged: (LocTag? value) {
                    setState(() {
                      _selectedLocationTag = value;
                    });
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oda Oluştur'),
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
            const SizedBox(height: 200),
            TextFormField(
              controller: _maxParticipantsController,
              decoration: const InputDecoration(
                labelText: 'Maksimum Katılımcı Sayısı',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _showLocationTagSelectionDialog,
              child: const Text('Lokasyon Tag Seç'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _createRoom,
              child: const Text('Odayı Oluştur ve Gir'),
            ),
          ],
        ),
      ),
    );
  }
}
