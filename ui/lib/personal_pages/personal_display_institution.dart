import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../classes/institution.dart';
import '../src/data/repositories/campaign_repository.dart';
import '../src/data/repositories/photo_repository.dart';
import 'package:farketmez/classes/campaign.dart';
import 'package:farketmez/classes/photo.dart';
import 'personal_use_campaign.dart';

class InstitutionDisplayPage extends StatefulWidget {
  final Institution institution;

  const InstitutionDisplayPage({super.key, required this.institution});

  @override
  State<InstitutionDisplayPage> createState() => _InstitutionDisplayPageState();
}

class _InstitutionDisplayPageState extends State<InstitutionDisplayPage> {
  final PhotoRepository _photoRepository = PhotoRepository();
  final DealsRepository _dealsRepository = DealsRepository();

  List<Campaign>? deals;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchDeals();
  }

  void fetchDeals() async {
    try {
      final dealsList = await _dealsRepository.getCampaigns(widget.institution.institutionId ?? 0);
      setState(() {
        deals = dealsList.isNotEmpty ? dealsList : [];
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
  Widget build(BuildContext context) {
    final LatLng coordinates = LatLng(widget.institution.latitude ?? 41.046541034532176, widget.institution.longitude ?? 29.033660876262047);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.institution.institutionName),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      widget.institution.institutionName,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.symmetric(vertical: 10),
              color: Colors.grey[500],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tags: ${widget.institution.tags.join(', ')}', style: const TextStyle(fontSize: 18)),
                  Text('Address: ${widget.institution.addressText}', style: const TextStyle(fontSize: 18)),
                  Text('Phone Number: ${widget.institution.phoneNumber}', style: const TextStyle(fontSize: 18)),
                ],
              ),
            ),
            FutureBuilder<List<Photo>>(
              future: _photoRepository.getPhotos(widget.institution.institutionId ?? 0),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8),
                          child: Image.memory(snapshot.data![index].data, fit: BoxFit.cover),
                        );
                      },
                    ),
                  );
                } else {
                  return const Text('No photos found.');
                }
              },
            ),
            SizedBox(
              height: 300,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: coordinates,
                  zoom: 14,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId(widget.institution.institutionName),
                    position: coordinates,
                  ),
                },
              ),
            ),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                    ? Text('Error: $errorMessage')
                    : deals!.isEmpty // Kampanya listesi boşsa bu kontrolü kullan
                        ? const Text('No deals available.') // Kampanya yoksa mesaj göster
                        : Container(
                            margin: const EdgeInsets.all(8),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: deals!.length,
                              itemBuilder: (context, index) {
                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                  child: ListTile(
                                    title: Text(deals![index].title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text(deals![index].description),
                                    onTap: () {
                                      openUseCampaign(context, deals![index]);
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
          ],
        ),
      ),
    );
  }

  void openUseCampaign(BuildContext context, Campaign campaign) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CampaignDetailPage(campaign: campaign),
    ),
  );
}
}
