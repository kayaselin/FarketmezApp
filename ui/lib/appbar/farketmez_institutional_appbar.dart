import 'package:flutter/material.dart';

class FarketmezInstitutionalAppbar extends StatelessWidget implements PreferredSizeWidget {
  const FarketmezInstitutionalAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('sayfa ismi gelebilir'),
      actions: <Widget>[
        const Text('Kurum adi'),
        IconButton(
          icon: const Icon(Icons.account_circle),
          onPressed: () {
            Navigator.pushNamed(context, '/institutionalProfilePage');
          },
        )
      ]
      
      // You can customize further, e.g., background color, leading widget, etc.
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
