import 'package:flutter/material.dart';
import '../classes/institution.dart';
import '../personal_pages/personal_display_institution.dart';

class InstitutionsListPage extends StatefulWidget {
  final List<Institution> institutions;
  final String tagName;

  const InstitutionsListPage({Key? key, required this.institutions, required this.tagName}) : super(key: key);

  @override
  _InstitutionsListPageState createState() => _InstitutionsListPageState();
}

class _InstitutionsListPageState extends State<InstitutionsListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kurumlar: ${widget.tagName}'),
      ),
      body: ListView.builder(
        itemCount: widget.institutions.length,
        itemBuilder: (context, index) {
          final institution = widget.institutions[index];
          return ListTile(
            title: Text(institution.institutionName),
            subtitle: Text(institution.addressText),
            onTap: () {
              // Kurum detay sayfasına yönlendir
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InstitutionDisplayPage(institution: institution),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
