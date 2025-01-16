import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../classes/campaign.dart';
import '../classes/token.dart';
import '../src/data/repositories/campaign_repository.dart';

class InstitutionalDealsPage extends StatefulWidget {
  const InstitutionalDealsPage({super.key});

  @override
  _InstitutionalDealsPageState createState() => _InstitutionalDealsPageState();
}

class _InstitutionalDealsPageState extends State<InstitutionalDealsPage> {
  final DealsRepository _dealsRepository = DealsRepository();
  List<Campaign>? deals;
  bool isLoading = true;
  String? errorMessage;

  void fetchDeals() async {
    try {
      final dealsList = await DealsRepository().getCampaigns(Token.institutionId);
      setState(() {
        deals = dealsList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDeals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Institutional Deals'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text('Error: $errorMessage'))
              : deals == null || deals!.isEmpty
                  ? const Center(child: Text('No deals available'))
                  : ListView.builder(
                      itemCount: deals!.length,
                      itemBuilder: (context, index) {
                        return DealCard(
                          campaign: deals![index],
                          onTap: () {
                            print('Kart tıklandı: ${deals![index].title}');
                          },
                          onLongPress: () async {
                            await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Delete Campaign'),
                                  content: Text('Are you sure you want to delete ${deals![index].title}?'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Cancel'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('Delete'),
                                      onPressed: () async {
                                        if (deals![index].campaignId != null) {
                                          await _dealsRepository.deleteCampaign(deals![index].campaignId!);
                                          fetchDeals(); // Listeyi yeniden yükle
                                          Navigator.of(context).pop();
                                        } else {
                                          Navigator.of(context).pop();
                                          // ID null ise hata mesajı göster
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Cannot delete this campaign. No ID found.')),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/institutionalCreateDealPage');
        },
        tooltip: 'Create Deal',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class DealCard extends StatelessWidget {
  final Campaign campaign;
  final Function() onTap;
  final Function() onLongPress;

  const DealCard({super.key, required this.campaign, required this.onTap, required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    String defphoto = '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';
    Uint8List bytes = base64.decode(campaign.photo ?? defphoto);
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Card(
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Row(
                      children: [
                        Image.memory(
                bytes,
                height: 50,
                width: 50,
              ),
                        Column(
                          children: [
                            Text(
                              campaign.title,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            
                            Text(
                              campaign.description,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}