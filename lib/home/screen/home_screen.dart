import 'dart:io';

import 'package:compressionvideosandimages/home/cubit/cubit.dart';
import 'package:compressionvideosandimages/home/cubit/state.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'imageview_file.dart';
import 'video_from_asset.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

CarouselSliderController buttonCarouselController = CarouselSliderController();
int currentIndex = 0;

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        var cubit = context.read<HomeCubit>();
        return Scaffold(
          body: ListView(
            children: [
              Container(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.width / 32),
                alignment: Alignment.centerRight,
                child: GestureDetector(
                    onTap: () async {
                      // await pickMltiImage();
                      cubit.showSelectionBottomSheet(
                          context); // await pickImage();
                    },
                    child: Image.asset(
                      'assets/images/66.png',
                      width: MediaQuery.of(context).size.width / 10,
                    )),
              ),
              (cubit.myImages != null && cubit.myImages!.isNotEmpty)
                  ? cubit.myImages!.length == 1
                      ? Container(
                          margin: EdgeInsets.all(
                              MediaQuery.of(context).size.width / 500),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    MediaQuery.of(context).size.width / 44),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ImageFileView(
                                                image: File(
                                                    cubit.myImages![0].path))));
                                  },
                                  child: Image.file(
                                    File(cubit.myImages![0].path),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height:
                                        MediaQuery.of(context).size.width / 2.5,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 5,
                                right: 5,
                                child: GestureDetector(
                                  onTap: () {
                                    cubit.deleteImage(
                                        File(cubit.myImages![0].path));
                                  },
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.red,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : CarouselSlider(
                          items: cubit.myImages!
                              .map((e) => Container(
                                    margin: EdgeInsets.all(
                                        MediaQuery.of(context).size.width /
                                            500),
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  44),
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ImageFileView(
                                                              image: File(
                                                                  e.path))));
                                            },
                                            child: Image.file(
                                              File(e.path),
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2.5,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 5,
                                          right: 5,
                                          child: GestureDetector(
                                            onTap: () {
                                              cubit.deleteImage(File(e.path));
                                            },
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.red,
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                          carouselController: buttonCarouselController,
                          options: CarouselOptions(
                              height: MediaQuery.of(context).size.width / 2.5,
                              autoPlay: false,
                              enlargeCenterPage: true,
                              viewportFraction: 1,
                              initialPage: 0,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  currentIndex = index;
                                });
                              }),
                        )
                  : Container(),
              cubit.validVideos.isEmpty
                  ? Container()
                  : cubit.validVideos.length == 1
                      ? Container(
                          margin: EdgeInsets.all(
                              MediaQuery.of(context).size.width / 500),
                          child: Stack(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height: MediaQuery.of(context).size.width / 2.5,
                                child: VideoPlayerScreenFromFile(
                                  videoFile: File(cubit.validVideos[0].path),
                                ),
                              ),
                              Positioned(
                                top: 5,
                                right: 5,
                                child: GestureDetector(
                                  onTap: () {
                                    cubit.deleteVideo(
                                        File(cubit.validVideos[0].path));
                                  },
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.red,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : CarouselSlider(
                          items: cubit.validVideos
                              .map((e) => Container(
                                    margin: EdgeInsets.all(
                                        MediaQuery.of(context).size.width /
                                            500),
                                    child: Stack(
                                      children: [
                                        SizedBox(
                                          width: double.infinity,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2.5,
                                          child: VideoPlayerScreenFromFile(
                                            videoFile: File(e.path),
                                          ),
                                        ),
                                        Positioned(
                                          top: 5,
                                          right: 5,
                                          child: GestureDetector(
                                            onTap: () {
                                              cubit.deleteVideo(File(e.path));
                                            },
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.red,
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                          carouselController: buttonCarouselController,
                          options: CarouselOptions(
                              height: MediaQuery.of(context).size.width / 2.5,
                              autoPlay: false,
                              enlargeCenterPage: true,
                              viewportFraction: 1,
                              initialPage: 0,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  currentIndex = index;
                                });
                              }),
                        ),
            ],
          ),
        );
      },
    );
  }
}
