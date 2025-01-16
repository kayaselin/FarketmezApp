import 'package:flutter/material.dart';
import '../classes/institution.dart';
import '../personal_pages/personal_display_institution.dart';

void openInstitutionPage(BuildContext context, Institution institution) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => InstitutionDisplayPage(institution: institution)),
  );
}
