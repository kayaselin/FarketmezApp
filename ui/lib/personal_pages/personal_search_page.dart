import 'package:farketmez/personal_pages/personal_display_institution.dart';
import 'package:flutter/material.dart';
import '../classes/institution.dart';
import '../classes/rating.dart';
import '/src/data/repositories/institution_repository.dart';

class PersonalSearchPage extends StatefulWidget {
  const PersonalSearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<PersonalSearchPage> {
  List<Institution> searchResults = [];
  final InstitutionRepository _institutionRepository = InstitutionRepository();

  @override
  void initState() {
    super.initState();
    _fetchInstitutions();
  }

  Future<void> _fetchInstitutions({String query = ''}) async {
    try {
      var institutions = await _institutionRepository.getInstitutions();
      // Genişletilmiş sorgu - isim, etiketler ve adres üzerinden filtreleme
      if (query.isNotEmpty) {
        institutions = institutions.where((institution) {
          final nameLower = institution.institutionName.toLowerCase();
          final addressLower = institution.addressText.toLowerCase();
          final tagsLower = institution.tags.map((tag) => tag.toLowerCase()).toList();
          final searchLower = query.toLowerCase();
          return nameLower.contains(searchLower) ||
                 addressLower.contains(searchLower) ||
                 tagsLower.any((tag) => tag.contains(searchLower));
        }).toList();
      }
      setState(() {
        searchResults = institutions;
      });
    } catch (e) {
      print('Kurum listesi çekilirken bir hata oluştu: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kurumları Ara'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'İsim, etiket veya adres ile ara',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (query) => _fetchInstitutions(query: query),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final institution = searchResults[index];
                return ListTile(
                  title: Text(institution.institutionName),
                  subtitle: Text(
                    'Puan: ${calculateAverageRating(institution.ratings)} ⭐️\nEtiketler: ${institution.tags.join(', ')}\nAdres: ${institution.addressText}',
                  ),
                  onTap: () => openInstitutionPage(context, institution),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  double calculateAverageRating(List<UserRating> ratings) {
    if (ratings.isEmpty) return 0.0;
    double total = ratings.fold(0.0, (sum, item) => sum + item.score);
    return total / ratings.length;
  }

  void openInstitutionPage(BuildContext context, Institution institution) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InstitutionDisplayPage(institution: institution),
      ),
    );
  }
}
