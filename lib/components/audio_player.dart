import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:itunes_music_player/provider/audio_provider.dart';
import 'package:itunes_music_player/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../services/audio_services.dart';

Widget audioPlayerWidget(context, {bool onWrapperApp = false}){
  Size size = MediaQuery.of(context).size;

  return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) async =>
          Provider.of<AudioProvider>(context, listen: false).clean(),
      child: Consumer<AudioProvider>(
        builder: (context, audioProvider, child){
          return AnimatedContainer(
              duration: const Duration(
                milliseconds: 350,
              ),
            child: (audioProvider.isPlayed || audioProvider.isPaused)
            ? Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    width: size.width * 0.9,
                    // height 155,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(left: 10, top: 7),
                              child: CachedNetworkImage(
                                imageUrl: audioProvider.cover!,
                                imageBuilder: (context, image){
                                  return Container(
                                    margin: const EdgeInsets.only(right: 6),
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                        image: image
                                      ),
                                    ),
                                  );
                                },
                                placeholder: (context, progress){
                                  return Shimmer.fromColors(
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 5),
                                      width: 35,
                                      height: 35,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadiusDirectional.circular(10),
                                      ),
                                    ),
                                    baseColor: const Color.fromARGB(255, 230, 230, 230),
                                    highlightColor: const Color.fromARGB(255, 212, 212, 212),
                                  );
                                },
                              ),
                            ),
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(top: 7),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      audioProvider.title!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      audioProvider.artist!,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 7, right: 10),
                              child: FutureBuilder<bool>(
                                future: AudioService.checkSavedMusic(audioProvider.music!),
                                initialData: false,
                                builder: (context, saved){
                                  return GestureDetector(
                                    onTap: () async {
                                      if(!saved.data!){
                                        await audioProvider.addToLibrary();
                                      }
                                    },
                                    child: FaIcon(
                                      saved.data!
                                          ? Icons.folder_zip_rounded
                                          : Icons.create_new_folder_rounded,
                                      color: Colors.white,
                                      size: 19,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.zero,
                          margin: const EdgeInsets.only(left: 10, right: 10),
                          child: StreamProvider<Duration>(
                            create: (_) => audioProvider.audioPlayer.positionStream,
                            initialData: const Duration(),
                            builder: (context, child){
                              double sliderValue = (audioProvider.audioPlayer.duration?.inMilliseconds.toDouble()
                              ?? 1.toDouble()) < Provider.of<Duration>(context).inMilliseconds
                                  .toDouble()
                                  ?(audioProvider.audioPlayer.duration
                              ?.inMilliseconds
                              .toDouble() ??
                              1.toDouble())
                                  : Provider.of<Duration>(context)
                                  .inMilliseconds
                                  .toDouble();
                              return Slider(
                                thumbColor: ColorTheme.color4,
                                activeColor: ColorTheme.color4,
                                inactiveColor: Colors.white.withOpacity(0.7),
                                min: 0,
                                max: (audioProvider.audioPlayer.duration
                                ?.inMilliseconds.toDouble() ??
                                    1.toDouble()),
                                value: sliderValue,
                                onChanged: (value) async {
                                  await audioProvider.seek(Duration(
                                    milliseconds: value.toInt()
                                  ));
                                },
                              );
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 10, right: 7),
                              padding: EdgeInsets.zero,
                              child: GestureDetector(
                                onTap: () async {
                                  await audioProvider.previous();
                                },
                                child: Icon(Icons.skip_previous_rounded,
                                  size: 40,
                                  color: ColorTheme.color3,
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: EdgeInsets.zero,
                              decoration: BoxDecoration(
                                color: ColorTheme.color4,
                                shape: BoxShape.circle,
                              ),
                              child: StreamProvider<Duration>(
                                create: (_) => audioProvider.audioPlayer.positionStream,
                                initialData: const Duration(),
                                builder: (context, child){
                                  double sliderValue = (audioProvider.audioPlayer.duration?.inMilliseconds.toDouble()
                                      ?? 1.toDouble()) < Provider.of<Duration>(context).inMilliseconds
                                      .toDouble()
                                      ?(audioProvider.audioPlayer.duration
                                      ?.inMilliseconds
                                      .toDouble() ??
                                      1.toDouble())
                                      : Provider.of<Duration>(context)
                                      .inMilliseconds
                                      .toDouble();
                                  double maxSliderValue = audioProvider
                                  .audioPlayer
                                  .duration
                                  !.inMilliseconds
                                  .toDouble();
                                  IconData icon = audioProvider.isPlayed
                                  ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded;
                                  if(sliderValue == maxSliderValue){
                                    if(audioProvider.isPlayed && onWrapperApp) {
                                      audioProvider.next();
                                    }
                                    }
                                    return IconButton(
                                      onPressed: () async {
                                        if(sliderValue == maxSliderValue){
                                          await audioProvider.seek(const Duration());
                                          return audioProvider.play();
                                        }
                                        (audioProvider.isPlayed
                                        ? audioProvider.pause
                                        : audioProvider.play
                                        )();
                                      },
                                      icon: Icon(
                                        icon,
                                        color: Colors.white,
                                        size: 33,
                                      ),
                                    );
                                },
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(left: 7, bottom: 10),
                              padding: EdgeInsets.zero,
                              child: GestureDetector(
                                onTap: () async {
                                  await audioProvider.next();
                                },
                                child: Icon(
                                  Icons.skip_next_rounded,
                                  size: 40,
                                  color: ColorTheme.color3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
                : const SizedBox(),
          );
        },
      ),
  );
}

