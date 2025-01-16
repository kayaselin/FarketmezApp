import 'dart:convert';
import 'package:flutter/material.dart';
import '../src/data/repositories/location_tags_repository.dart';
import '../src/data/repositories/tag_repository.dart';
import 'package:farketmez/classes/location_tag.dart';
import 'package:farketmez/classes/tag.dart';
import 'package:farketmez/classes/institution.dart';
import '../src/data/repositories/institution_repository.dart';
import 'institutional_login_page.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class InstitutionalRegisterScreen extends StatefulWidget {
  const InstitutionalRegisterScreen({super.key});

  @override
  State<InstitutionalRegisterScreen> createState() =>
      _InstitutionalRegisterScreenState();
}

class _InstitutionalRegisterScreenState
    extends State<InstitutionalRegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _profilePicController = TextEditingController();
  final List<int> _selectedTagIDs = []; // Seçilen tag'lerin ID'lerini saklamak için
  List<Tag> _tags = [];
  final TagRepository _tagRepository = TagRepository();
  final LocationTagsRepository _locationTagsRepository =
      LocationTagsRepository();
  List<LocTag> _locationTags = [];
  LocTag? _selectedLocationTag;
  LatLng _selectedCoordinates = const LatLng(41.00199298402444, 29.17619131949453);
  late GoogleMapController mapController;
  final Set<Marker> _markers = {};


  @override
  void initState() {
    super.initState();
    _fetchTags();
    _fetchLocationTags();
  }

  Future<void> _fetchTags() async {
    try {
      var tags = await _tagRepository.getTags();
      setState(() {
        _tags = tags;
      });
    } catch (e) {
      print('Tag listesi çekilirken bir hata oluştu: $e');
    }
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

  void _onMapCreated(GoogleMapController controller) {
  mapController = controller;
}


  void _onTap(LatLng location) {
  setState(() {
    _selectedCoordinates = location;
    // Haritada yalnızca bir marker göstermek için _markers setini temizleyin
    _markers.clear(); 
    // Yeni marker'ı _markers setine ekleyin
    _markers.add(
      Marker(
        markerId: MarkerId(location.toString()), // Her marker için benzersiz bir ID oluşturun
        position: location, // Marker'ın konumu
        infoWindow: const InfoWindow(title: 'Seçilen Konum'), // Opsiyonel: Marker'a tıklanıldığında gösterilecek bilgi penceresi
      ),
    );
  });
  mapController.moveCamera(CameraUpdate.newLatLng(location));
}

  void _showTagSelectionDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Tag Seçimi"),
          content: SingleChildScrollView(
            child: ListBody(
              children: _tags.map((tag) {
                return CheckboxListTile(
                  title: Text(tag.tagName),
                  value: _selectedTagIDs
                      .contains(tag.tagId), // Kontrol için ID'yi kullanın
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedTagIDs
                            .add(tag.tagId); // Seçilen tag'in ID'sini ekleyin
                      } else {
                        _selectedTagIDs.remove(tag
                            .tagId); // Seçimi kaldırılan tag'in ID'sini çıkarın
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Tamam"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showMapDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Varsayılan bir başlangıç konumu
        return AlertDialog(
          title: const Text("Konum Seç"),
          content: SizedBox(
            width: double.maxFinite,
            height: 300, // Diyalogun boyutunu ayarlayabilirsiniz
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _selectedCoordinates,
                zoom: 10.0,
                
              ),
              markers: _markers,
              onTap: _onTap,
              // Haritanın diğer özelliklerini ve ayarlarını buraya ekleyebilirsiniz
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Tamam'),
              onPressed: () {
                // Tamam butonuna basıldığında, kullanıcının seçtiği konumu kullanarak yapmak istediğiniz işlemleri burada gerçekleştirin
                // Örneğin, _currentSelectedLocation'u `Institution` nesnesine ekleyebilirsiniz
                Navigator.of(context).pop(); // Diyalogu kapat
              },
            ),
          ],
        );
      },
    );
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

  void _registerInstitution() async {
    // Kurum kaydı için Institution nesnesi oluşturuluyor, institutionId dahil edilmiyor
    final institution = Institution(
        institutionName: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        addressText: _addressController.text,
        profilePic: _profilePicController
            .text, // Kullanıcı girişi veya varsayılan bir değer
        locTagId: _selectedLocationTag?.locTagId ?? 0, // Kullanıcı seçimi
        phoneNumber: _phoneController.text,
        //ratings: [], // Bu örnekte boş bir liste, gerekirse doldurulabilir
        tags: _selectedTagIDs
            .map((id) => id.toString())
            .toList(), // Seçilen tag ID'lerini gönder
        latitude: _selectedCoordinates.latitude,
        longitude: _selectedCoordinates.longitude);

    try {
      final response =
          await InstitutionRepository().createInstitution(institution);
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Yanıttan kurumun ID'sini çıkar
        final responseData = json.decode(response.body);
        final newInstitutionId = responseData['institution_id'];
        print('Yeni kurum ID: $newInstitutionId');

        // Kurum ID'si ile ilgili işlemler burada yapılabilir
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Kurum kaydı başarılı. ID: $newInstitutionId')));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const InstitutionalLoginPage()), // LoginScreen, giriş sayfanızın adıdır
        );
      } else {
        // Kayıt başarısız oldu, hata mesajını göster
        print('Durum Kodu: ${response.statusCode}');
        print(jsonEncode(institution.toJson()));

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text('Kayıt sırasında bir hata oluştu: ${response.body}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Bir hata oluştu: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Institutional User Registration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Institution Name',
              ),
            ),
            // Diğer TextField'lar...
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Institution Address',
              ),
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showLocationTagSelectionDialog,
              child: const Text('Lokasyon Tag Seç'),
            ),
            ElevatedButton(
              onPressed: _showMapDialog, // Diyalog gösterme fonksiyonunu çağır
              child: const Text('Konum Seç'),
            ),
            ElevatedButton(
              onPressed: _showTagSelectionDialog,
              child: const Text('Tag Seç'),
            ),
            ElevatedButton(
              onPressed: _registerInstitution,
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
