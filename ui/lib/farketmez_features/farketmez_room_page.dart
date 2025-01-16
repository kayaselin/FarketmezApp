import 'dart:async';
import 'package:flutter/material.dart';
import 'package:farketmez/classes/tag.dart';
import '../src/data/repositories/tag_repository.dart';
import '../src/data/repositories/farketmez_repository.dart';
import 'package:farketmez/classes/token.dart';
import 'institutions_list_page.dart';

class FarketmezRoomPage extends StatefulWidget {
  final int roomId;
  final int? locationTagId;
  final String? districtName;
  final int? userId;
  final bool isAdmin;

  const FarketmezRoomPage({
    Key? key,
    required this.roomId,
    this.locationTagId,
    this.districtName,
    this.userId,
    required this.isAdmin,
  }) : super(key: key);

  @override
  _FarketmezRoomPageState createState() => _FarketmezRoomPageState();
}

class _FarketmezRoomPageState extends State<FarketmezRoomPage> {
  final TagRepository _tagRepository = TagRepository();
  final FarketmezRepository _farketmezRepository = FarketmezRepository();
  List<Tag> tags = [];
  String searchQuery = '';
  int? _selectedTagId;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _fetchTags();
    _startPollingForVoteCompletion();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchTags() async {
    try {
      tags = await _tagRepository.getTags();
      setState(() {});
    } catch (e) {
      print("Tag'ler çekilirken bir hata oluştu: $e");
    }
  }

  void _submitVote() async {
    if (_selectedTagId != null) {
      bool success = await _farketmezRepository.submitTags(Token.userId, widget.roomId, _selectedTagId!);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tag başarıyla seçildi.')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tag seçimi başarısız oldu.')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen bir tag seçin.')));
    }
  }

  void _finishVoting() async {
    try {
      var results = await _farketmezRepository.checkAndListInstitutions(widget.roomId);
      if (results['message'] != null) {
        // Eğer API'den bir hata mesajı varsa, bu mesajı kullanıcıya göster
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(results['message'])));
      } else {
        // Beklenen sonuçlar alınamadıysa, genel bir hata mesajı göster
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lutfen oylamanin bitmesini ya da polling suresini bekleyiniz.")));
      }
    } catch (e) {
      // Yakalanan herhangi bir hata için kullanıcıya hata mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bir hata oluştu. Lütfen daha sonra tekrar deneyiniz.")));
    }
  }

  void _startPollingForVoteCompletion() {
    _pollingTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
      bool isFinished = await _farketmezRepository.checkIfVotingFinished(widget.roomId);
      if (isFinished) {
        timer.cancel();
        // Eğer oylama tamamlandıysa sonuçları göstermek için bir yönlendirme yap
        _navigateToVotingResults();
      }
    });
  }

  void _navigateToVotingResults() async {
  // Oylama sonucunu kontrol et ve sonuçları al
  var results = await _farketmezRepository.checkAndListInstitutions(widget.roomId);
  if (results.isNotEmpty && results['institutions'] != null && results['tagName'] != null) {
    // Sonuçlar mevcutsa ve tagName null değilse, sonuç sayfasına yönlendir
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => InstitutionsListPage(
          institutions: results['institutions'], // institutions listesini geç
          tagName: results['tagName'], // tagName'i geç
        ),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Oda: ${widget.roomId} - ${widget.districtName ?? ''}'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Tag Ara',
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tags.length,
              itemBuilder: (context, index) {
                final tag = tags[index];
                return Visibility(
                  visible: tag.tagName.toLowerCase().contains(searchQuery.toLowerCase()),
                  child: RadioListTile<int>(
                    title: Text(tag.tagName),
                    value: tag.tagId,
                    groupValue: _selectedTagId,
                    onChanged: (int? value) {
                      setState(() {
                        _selectedTagId = value;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: "voteBtn",
            onPressed: _submitVote,
            label: const Text('Oyla'),
            icon: const Icon(Icons.check),
          ),
          SizedBox(height: widget.isAdmin ? 20 : 0),
          widget.isAdmin
              ? FloatingActionButton.extended(
                  heroTag: "finishVotingBtn",
                  onPressed: _finishVoting,
                  label: const Text('Oylamayı Bitir'),
                  icon: const Icon(Icons.check_circle),
                )
              : Container(),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
