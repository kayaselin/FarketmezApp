import 'package:flutter/material.dart';

class FarketmezPersonalAppbar extends StatelessWidget implements PreferredSizeWidget {
  const FarketmezPersonalAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('sayfa ismi gelebilir'),
      actions: <Widget>[
        const Text('Kullanici adi'),
        IconButton(
          icon: const Icon(Icons.account_circle),
          onPressed: () {
            Navigator.pushNamed(context, '/personalProfilePage');
          },
        )
      ]
      
      // You can customize further, e.g., background color, leading widget, etc.
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
