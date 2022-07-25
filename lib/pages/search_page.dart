import 'package:flutter/material.dart';
import 'package:itunes_music_player/components/music.dart';
import 'package:itunes_music_player/provider/audio_provider.dart';
import 'package:itunes_music_player/provider/search_provider.dart';
import 'package:provider/provider.dart';
import '../models/music.dart';
import '../utils/colors.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: ColorTheme.color1,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Consumer<SearchProvider>(builder: (context, searchProvider, child) {
              List<Music> listMusic = searchProvider.search ?? [];
              return Opacity(
                opacity: listMusic.isEmpty ? 1 : 0.6,
                child: Container(
                  height: 200,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/search_image.png'),
                        fit: BoxFit.cover),
                  ),
                  child: Row(),
                ),
              );
            }),
            Consumer<SearchProvider>(
              builder: (context, searchProvider, child) {
                List<Music> listMusic = searchProvider.search ?? [];
                return ListView(
                  children: [
                    Column(
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          child: listMusic.isEmpty
                              ? Container(
                                  key: UniqueKey(),
                                  margin:
                                      EdgeInsets.only(top: size.height * 0.37),
                                  child: Text(
                                    'Search music for your moods.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: ColorTheme.color3,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : SizedBox(
                                  key: UniqueKey(),
                                ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.only(
                              left: 15, right: 15, top: 3),
                          margin: EdgeInsets.only(
                            left: size.width * 0.05,
                            right: size.width * 0.05,
                            top: 15,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.1),
                                spreadRadius: 5,
                                blurRadius: 10,
                                offset: const Offset(0, 6),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: TextField(
                            onSubmitted: (keyword) async {
                              if (!searchProvider.loadingSearch) {
                                await searchProvider.searchMusic(keyword);
                              }
                            },
                            textInputAction: TextInputAction.search,
                            cursorColor: ColorTheme.color4,
                            controller: searchProvider.searchController,
                            decoration: InputDecoration(
                                hintText: 'Search Music...',
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                suffixIcon: GestureDetector(
                                  onTap: () async {
                                    if (!searchProvider.loadingSearch) {
                                      await searchProvider.searchMusic(
                                          searchProvider.searchController.text);
                                      FocusScope.of(context)
                                          .requestFocus(FocusNode());
                                    }
                                  },
                                  child: Icon(
                                    Icons.search_rounded,
                                    color: ColorTheme.color4,
                                    size: 30,
                                  ),
                                )),
                          ),
                        ),
                      ],
                    ),
                    listMusic.isEmpty
                        ? const SizedBox()
                        : Column(
                            children: [
                              const SizedBox(
                                height: 50,
                              ),
                              ...listMusic
                                  .map((music) => musicWidget(context, music,
                                      listMusic, SourceMusic.search))
                                  .toList(),
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
                              )
                            ],
                          )
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
