import 'package:flutter/material.dart';
import '../src/data/repositories/campaign_repository.dart';
import 'package:farketmez/classes/token.dart';
import 'package:farketmez/classes/campaign.dart';

class InstitutionalStatisticsPage extends StatefulWidget {
  const InstitutionalStatisticsPage({super.key});

  @override
  _InstitutionalStatisticsPageState createState() => _InstitutionalStatisticsPageState();
}

class _InstitutionalStatisticsPageState extends State<InstitutionalStatisticsPage> {
  final DealsRepository _dealsRepository = DealsRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kurum Istatistikleri'),
      ),
      body: FutureBuilder<List<Campaign>>(
        future: _dealsRepository.getCampaignStatistics(Token.institutionId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final campaigns = snapshot.data!;
            return ListView.builder(
              itemCount: campaigns.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 4,
                        child: ListTile(
                          title: Text(campaigns[index].title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(campaigns[index].description,),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 6.0),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey[100],
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Text(
                            '${campaigns[index].totalUses} Uses',
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('Veri bulunamadı'));
          }
        },
      ),
    );
  }
}
