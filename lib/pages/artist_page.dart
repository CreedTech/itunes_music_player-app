import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:itunes_music_player/components/audio_player.dart';
import 'package:itunes_music_player/components/music.dart';
import 'package:itunes_music_player/models/artist.dart';
import 'package:itunes_music_player/provider/audio_provider.dart';
import 'package:itunes_music_player/services/audio_services.dart';
import 'package:itunes_music_player/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../models/music.dart';

class ArtistPage extends StatelessWidget {
  final Artist popularArtist;
  const ArtistPage(this.popularArtist, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: ColorTheme.color1,
      body: SafeArea(
        child: FutureProvider<List<Music>>(
          create: (_) => AudioService.search(popularArtist.keywordSearch!),
          initialData: const [],
          builder: (context, child) {
            return Stack(
              alignment: Alignment.bottomCenter,
              children: [
                ListView(
                  children: [
                    Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            Container(
                              height: size.height * 0.40,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('assets/images/artist.png'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Row(),
                            ),
                            Container(
                              height: size.height * 0.40,
                              color: const Color(0xff5e6372).withOpacity(0.50),
                              child: Row(),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: size.height * 0.05),
                              child: Column(
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: popularArtist.image,
                                    imageBuilder: (context, image) {
                                      return Container(
                                        height: size.width * 0.35,
                                        width: size.width * 0.35,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            image: image,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      );
                                    },
                                    placeholder: (context, progress) {
                                      return Shimmer.fromColors(
                                        child: Container(
                                          width: size.width * 0.35,
                                          height: size.width * 0.35,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                          ),
                                        ),
                                        baseColor: const Color.fromARGB(
                                            255, 95, 125, 156),
                                        highlightColor: const Color.fromARGB(
                                            255, 65, 95, 124),
                                      );
                                    },
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      popularArtist.name,
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 2),
                                    child: Consumer<List<Music>>(
                                      builder: (context, listMusic, child) {
                                        int countMusic = listMusic
                                            .where((music) =>
                                                music.artist ==
                                                popularArtist.name)
                                            .length;
                                        return Text(
                                          '$countMusic Songs',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.white,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    margin: const EdgeInsets.only(
                                        left: 15, top: 17),
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: ColorTheme.color1,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.arrow_back_ios_rounded,
                                      color: Colors.white,
                                      size: 25,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: ColorTheme.color1,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(45),
                              topRight: Radius.circular(45),
                            ),
                          ),
                          width: size.width,
                          constraints:
                              BoxConstraints(minHeight: size.height * 0.7),
                          margin: EdgeInsets.only(top: size.height * 0.3),
                          child: Consumer<List<Music>>(
                            builder: (context, listMusic, child) {
                              listMusic = listMusic
                                  .where((music) =>
                                      music.artist == popularArtist.name)
                                  .toList();
                              List<Widget> listMusicWidget = listMusic
                                  .map((music) => musicWidget(context, music,
                                      listMusic, SourceMusic.popularArtist))
                                  .toList();
                              return Column(
                                children: [
                                  const SizedBox(
                                    height: 25,
                                  ),
                                  ...listMusicWidget,
                                  Consumer<AudioProvider>(
                                    builder: (context, audioProvider, child) {
                                      return AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 400),
                                          height: audioProvider.isPlayed ||
                                                  audioProvider.isPaused
                                              ? 200
                                              : 0);
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                audioPlayerWidget(context)
              ],
            );
          },
        ),
      ),
    );
  }
}
