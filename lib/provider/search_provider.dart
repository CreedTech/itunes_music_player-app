import 'package:flutter/material.dart';
import 'package:itunes_music_player/models/music.dart';
import 'package:itunes_music_player/services/audio_services.dart';

class SearchProvider with ChangeNotifier {
  TextEditingController searchController = TextEditingController();
  String? keyword;
  List<Music>? search;
  bool loadingSearch = false;


  Future searchMusic(String keyword) async {
    loadingSearch = true;
    notifyListeners();
    search = (await AudioService.search(keyword)).cast<Music>();
    loadingSearch = false;
    notifyListeners();
  }
}