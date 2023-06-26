import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:itunes_music_player/models/artist.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:itunes_music_player/models/music.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart';
import 'package:html/parser.dart';

class AudioService {
  static Future<Box<Music>> getBox() => Hive.openBox<Music>('music_player');
  static Box<Music> musicPlayerBox = Hive.box<Music>('music_player');

  static Future<List<Music>> search(String keyword) async {
    keyword = keyword.replaceAll(' ', '+').toLowerCase();
    Uri url = Uri.parse(
        "https://itunes.apple.com/search?term=$keyword&entity=musicTrack");
    http.Response response = await http.get(url);
    if (response.statusCode == 200) {
      Map musics = json.decode(response.body);
      return List<Map>.from(musics['results']).map((e) {
        return Music(
          e['trackId'],
          e['artistName'],
          e['artworkUrl100'],
          e['previewUrl'],
          e['trackName'],
          e['trackTimeMills'],
          e['artistViewUrl'],
        );
      }).toList();
    }
    return [];
  }
  // 1452940717

  static Future<String?> getImageArtist(String url) async {
    http.Response response = await http.get(Uri.parse(url));
    Document html = parse(response.body);
    String? image;
    try {
      List<Element> elements =
          html.getElementsByClassName('circular-artwork__artwork');
      List<Element> element = elements[0].getElementsByTagName('source');
      image = element[1].attributes['srcset'];
      return image?.split(', ').last.replaceAll(' 380w', 'replace');
    } catch (e) {
      print('No Element');
    }
    return image;
  }

  static Future<List<Artist>> getPopularArtist() async {
    var popular = {
      "popular_artist": [
        {
          "name": "Kunto Aji",
          "url": "https://music.apple.com/us/artist/kunto-aji/636803660"
        },
        {
          "name": "Hindia",
          "url": "https://music.apple.com/us/artist/hindia/1440146558"
        },
        {
          "name": "Barasuara",
          "url": "https://music.apple.com/us/artist/barasuara/1039595097"
        },
        {
          "name": "Bring Me The Horizon",
          "url":
              "https://music.apple.com/us/artist/bring-me-the-horizon/121043936"
        },
        {
          "name": "Shawn Mendes",
          "url": "https://music.apple.com/us/artist/shawn-mendes/890403665"
        },
        {
          "name": "Tulus",
          "url": "https://music.apple.com/us/artist/tulus/1001681665"
        },
        {
          "name": "Ardhito Pramono",
          "url": "https://music.apple.com/us/artist/ardhito-pramono/1219784065"
        },
        {
          "name": "Rich Brian",
          "url": "https://music.apple.com/us/artist/rich-brian/1023207266"
        }
      ]
    };
    String response = popular as String;
    print(response);
    return List<Map>.from(json.decode(response)['artists']).map((p) {
      return Artist(
        p['name'],
        p['url'],
      );
    }).toList();

    // String response = await rootBundle.loadString('assets/db.json');
    // return List<Map>.from(json.decode(response)['artists']).map((p) {
    //   return Artist(
    //     p['name'],
    //     p['url'],
    //   );
    // }).toList();
  }

  static Future<MusicResponse> save(Music music) async {
    Box<Music> box = await getBox();
    if (box.values.toList().where((m) => m.id == music.id).isEmpty) {
      await box.add(music);
      return MusicResponse.success;
    }
    return MusicResponse.musicExist;
  }

  static Future<List<Music>> getSavedMusic() async {
    Box<Music> box = await getBox();
    return box.values.toList();
  }

  static Future<ValueListenable<Box<Music>>> streamSavedMusic() async {
    await getBox();
    return musicPlayerBox.listenable();
  }

  static Future<bool> checkSavedMusic(Music music) async {
    Box<Music> box = await getBox();
    return box.values.toList().where((m) => m.id == music.id).isNotEmpty;
  }

  static Future remove(Music music) async {
    Box<Music> box = await getBox();
    int id = box.values
        .toList()
        .asMap()
        .entries
        .where((m) => m.value.id == music.id)
        .first
        .key;
    await box.deleteAt(id);
  }
}

enum MusicResponse {
  success,
  musicExist,
}
