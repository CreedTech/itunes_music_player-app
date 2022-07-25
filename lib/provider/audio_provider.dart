import 'package:flutter/material.dart';
import 'package:itunes_music_player/models/music.dart';
import 'package:itunes_music_player/services/audio_services.dart';
import 'package:just_audio/just_audio.dart';

enum SourceMusic { popularArtist, search, library }

class AudioProvider with ChangeNotifier {
  final AudioPlayer audioPlayer = AudioPlayer();
  bool isPlayed = false;
  bool isPaused = false;
  String? cover;
  String? artist;
  String? title;
  String? artistUrl;
  int? trackTimeMillis;
  Music? music;
  List<Music>? listMusic;
  bool loadingLibrary = false;
  SourceMusic? sourceMusic;

  Future pause() async {
    isPaused = true;
    isPlayed = false;
    await audioPlayer.pause();
    notifyListeners();
  }

  Future play() async {
    isPaused = false;
    isPlayed = true;
    await audioPlayer.play();
    notifyListeners();
  }

  Future playSource(Music music, List<Music> listMusic, SourceMusic source) async {
    this.music = music;
    artist = music.artist;
    title = music.title;
    artistUrl = music.artistUrl;
    cover = music.cover;
    trackTimeMillis = music.trackTimeMillis;
    listMusic = listMusic;
    sourceMusic = source;
    isPlayed = true;
    isPaused = false;
    await audioPlayer.setUrl(music.url);
    audioPlayer.play();
    notifyListeners();
  }

  Future seek(Duration time) async {
    await audioPlayer.seek(time);
  }

  Future addToLibrary() async {
    loadingLibrary = true;
    notifyListeners();
    await AudioService.save(music!);
    loadingLibrary = false;
    notifyListeners();
  }

  Future next() async {
    List<int?> listIndexMusic = listMusic!
    .asMap()
        .entries
        .map((m) => m.value.id == this.music!.id ?  m.key : null).toList()
        .cast<int?>();
    listIndexMusic.removeWhere((element) => element == null);
    Music music = listMusic![
    (listIndexMusic.first! + 1) > (listMusic!.length - 1)
        ? (listIndexMusic.length - 1)
    : (listIndexMusic.first! + 1)];
    await playSource(music, listMusic!, sourceMusic!);
  }
  Future previous() async {
    List<int?> listIndexMusic = listMusic!
    .asMap()
        .entries
        .map((m) => m.value.id == this.music!.id ?  m.key : null).toList()
        .cast<int?>();
    listIndexMusic.removeWhere((element) => element == null);
    Music music = listMusic![
    (listIndexMusic.first! - 1) < 0
        ? 0
    : (listIndexMusic.first! - 1)];
    await playSource(music, listMusic!, sourceMusic!);
  }

  clean() async {
    await audioPlayer.pause();
    isPlayed = false;
    isPaused = false;
    cover = null;
    artist = null;
    title = null;
    artistUrl = null;
    trackTimeMillis = null;
    music = null;
    listMusic = null;
    sourceMusic = null;
    loadingLibrary = false;
    notifyListeners();
  }

  removeMusic(Music music) async {
    if(this.music!.id == music.id) await next();
    listMusic = listMusic!.where((m) => m.id != music.id).toList();
    notifyListeners();
  }
}
