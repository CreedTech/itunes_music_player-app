import 'package:flutter/material.dart';
import 'package:itunes_music_player/components/audio_player.dart';
import 'package:itunes_music_player/pages/dashboard_page.dart';
import 'package:itunes_music_player/pages/search_page.dart';
import 'package:itunes_music_player/provider/app_provider.dart';
import 'package:itunes_music_player/utils/colors.dart';
import 'package:provider/provider.dart';
import '../provider/audio_provider.dart';
import '../provider/search_provider.dart';
import 'library_page.dart';

class WrapperApp extends StatelessWidget {
  WrapperApp({Key? key}) : super(key: key);

  final PageController pageController = PageController();
  Future changePage(context, int index) async {
    Provider.of<AppProvider>(context, listen: false).changePage(index);
    await pageController.animateToPage(index,
        duration: const Duration(milliseconds: 350), curve: Curves.easeIn);
  }

  Widget navbarWidget(context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      height: 65.5,
      padding:
          EdgeInsets.only(left: size.width * 0.13, right: size.width * 0.13),
      decoration: BoxDecoration(
        color: ColorTheme.color1,
      ),
      child: BottomNavigationBar(
        onTap: (index) async => await changePage(context, index),
        elevation: 0,
        backgroundColor: Colors.transparent,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: Column(
              children: [
                Icon(
                  Icons.home_rounded,
                  size: 26,
                  color: ColorTheme.color5,
                ),
                Consumer<AppProvider>(
                  builder: (context, appProvider, child) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      child: appProvider.page == 0
                          ? Container(
                              key: UniqueKey(),
                              margin: const EdgeInsets.only(top: 6),
                              padding: EdgeInsets.zero,
                              decoration: BoxDecoration(
                                color: ColorTheme.color5,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              width: 22,
                              height: 3.2,
                            )
                          : SizedBox(
                              key: UniqueKey(),
                            ),
                    );
                  },
                ),
              ],
            ),
            label: 'Calls',
          ),
          BottomNavigationBarItem(
            icon: Column(
              children: [
                Icon(
                  Icons.search_rounded,
                  size: 26,
                  color: ColorTheme.color5,
                ),
                Consumer<AppProvider>(
                  builder: (context, appProvider, child) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      child: appProvider.page == 1
                          ? Container(
                              key: UniqueKey(),
                              margin: const EdgeInsets.only(top: 6),
                              padding: EdgeInsets.zero,
                              decoration: BoxDecoration(
                                color: ColorTheme.color5,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              width: 22,
                              height: 3.2,
                            )
                          : SizedBox(
                              key: UniqueKey(),
                            ),
                    );
                  },
                ),
              ],
            ),
            label: 'Camera',
          ),
          BottomNavigationBarItem(
            icon: Column(
              children: [
                Icon(
                  Icons.library_music_rounded,
                  size: 26,
                  color: ColorTheme.color5,
                ),
                Consumer<AppProvider>(
                  builder: (context, appProvider, child) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      child: appProvider.page == 2
                          ? Container(
                              key: UniqueKey(),
                              margin: const EdgeInsets.only(top: 6),
                              padding: EdgeInsets.zero,
                              decoration: BoxDecoration(
                                color: ColorTheme.color5,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              width: 22,
                              height: 3.2,
                            )
                          : SizedBox(
                              key: UniqueKey(),
                            ),
                    );
                  },
                ),
              ],
            ),
            label: 'Chats',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppProvider>(create: (_) => AppProvider()),
        ChangeNotifierProvider<AudioProvider>(create: (_) => AudioProvider()),
        ChangeNotifierProvider<SearchProvider>(create: (_) => SearchProvider()),
      ],
      builder: (context, child) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          bottomNavigationBar: navbarWidget(context),
          body: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              PageView(
                controller: pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  DashBoardPage((index) => changePage(context, index)),
                  const SearchPage(),
                  LibraryPage((index) => changePage(context, index)),
                ],
              ),
              audioPlayerWidget(context, onWrapperApp: true),
              Consumer2<SearchProvider, AudioProvider>(
                builder: (context, searchProvider, audioProvider, child) {
                  if (searchProvider.loadingSearch ||
                      audioProvider.loadingLibrary) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 8,
                              ),
                            ],
                            color: ColorTheme.color4,
                          ),
                          height: 40,
                          width: 40,
                          margin: const EdgeInsets.all(5),
                          child: const CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return const SizedBox();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
