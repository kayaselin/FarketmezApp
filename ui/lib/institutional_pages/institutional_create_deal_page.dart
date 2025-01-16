import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:farketmez/classes/campaign.dart';
import 'package:farketmez/classes/token.dart';
import '../src/data/repositories/campaign_repository.dart';
import 'package:farketmez/classes/photo.dart';

class InstitutionalCreateDealPage extends StatefulWidget {
  const InstitutionalCreateDealPage({super.key});

  @override
  State<InstitutionalCreateDealPage> createState() => _InstitutionalCreateDealPageState();
}

class _InstitutionalCreateDealPageState extends State<InstitutionalCreateDealPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final DealsRepository campaignRepository = DealsRepository();
  String? _base64Image;
  late Future<Photo> photoFuture;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _base64Image = await encodeImageToBase64(pickedFile.path);
      setState(() {}); // Eğer UI'da bir değişiklik yapılacaksa
    }
  }

  Future<String> encodeImageToBase64(String imagePath) async {
    File imageFile = File(imagePath);
    final bytes = await imageFile.readAsBytes();
    return base64Encode(bytes);
  }

  

  Future<void> _submitDeal() async {
    final campaign = Campaign(
      institutionId: Token.institutionId,
      title: _titleController.text,
      description: _descriptionController.text,
      base64Image: _base64Image,
    );
    final response = await campaignRepository.createCampaign(campaign, Token.institutionId);
    if (response.statusCode == 201) {
      // İşlem başarılı
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deal successfully created')),
      );
    } else {
      // Hata işleme
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create deal')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a Deal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.pushNamed(context, '/institutionalProfilePage');
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20.0),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Başlık',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Fotoğraf Ekle'),
            ),
            const SizedBox(height: 75.0),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Açıklama Metni',
                border: OutlineInputBorder(),
              ),
              maxLines: 10,
            ),
            const SizedBox(height: 50.0),
            ElevatedButton(
              onPressed: _submitDeal,
              child: const Text('Kampanya Oluştur'),
            ),
          ],
        ),
      ),
    );
  }
}