import 'dart:typed_data';

class Photo {
  final int id;
  final Uint8List data;

  Photo({required this.id, required this.data});
}
