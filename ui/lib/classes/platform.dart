import 'package:flutter/widgets.dart';
import 'dart:io';

class PlatformProvider extends ChangeNotifier {
  String platformurl = 'localhost';

  PlatformProvider() {
    if (Platform.isAndroid) {
      platformurl = '10.0.2.2';
    }
  }
}

  

