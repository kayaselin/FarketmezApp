import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:farketmez/classes/token.dart';
import 'package:farketmez/classes/photo.dart';
import '../src/data/repositories/photo_repository.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class PhotoGallery extends StatefulWidget {
  const PhotoGallery({super.key});

  @override
  _PhotoGalleryState createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends State<PhotoGallery> {
  late Future<List<Photo>> photosFuture;
  final PhotoRepository photoRepository = PhotoRepository();

  @override
  void initState() {
    super.initState();
    photosFuture = photoRepository.getPhotos(Token.institutionId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Gallery'),
      ),
      body: Center(
        child: FutureBuilder<List<Photo>>(
          future: photosFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 4.0,
                ),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final photo = snapshot.data![index];
                  return GestureDetector(
                    onTap: () => _showPhoto(context, photo.data),
                    onLongPress: () => _confirmDelete(context, photo.id),
                    child: Image.memory(photo.data, fit: BoxFit.cover),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Text("Error loading images: ${snapshot.error}");
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => navigateToGallery(),
        tooltip: 'Add Photo',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showPhoto(BuildContext context, Uint8List photo) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Image.memory(photo, fit: BoxFit.cover),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int photoId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this photo?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Delete'),
            onPressed: () {
              photoRepository.deletePhoto(photoId).then((_) {
                Navigator.of(context).pop();
                setState(() {
                  photosFuture = photoRepository.getPhotos(Token.institutionId); // Güncellenmiş listeyi yeniden yükle
                });
              }).catchError((error) {
                Navigator.of(context).pop();
                // Hata mesajı göster
                final snackBar = SnackBar(content: Text('Error deleting photo: $error'));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              });
            },
          ),
        ],
      ),
    );
  }

  Future<void> navigateToGallery() async {
  final ImagePicker picker = ImagePicker();
  // Kullanıcıdan bir fotoğraf seçmesini isteyin
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);

  if (image != null) {
    // Seçilen fotoğrafı File nesnesine dönüştürün
    File imageFile = File(image.path);

    // Fotoğrafı base64 string'e dönüştürün
    String base64Image = base64Encode(await imageFile.readAsBytes());
    photoRepository.addPhoto(base64Image, Token.institutionId);
    setState(() {
      photosFuture = photoRepository.getPhotos(Token.institutionId);
    });

    // Burada base64Image'i API'ye gönderme işlemini yapabilirsiniz
    // Örnek: await sendImageToApi(base64Image);
  }
}
}