import 'dart:io';

import 'package:compressionvideosandimages/home/cubit/cubit.dart';
import 'package:compressionvideosandimages/home/cubit/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:carousel_slider/carousel_slider.dart';

import 'package:photo_view/photo_view.dart';

import 'flutter_toast.dart';

class ImageView extends StatefulWidget {
  ImageView({required this.image, this.isAsset = false, super.key});
  String? image;
  bool? isAsset;
  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  @override
  void initState() {
    print('00000:${widget.image} : ${widget.isAsset}');
    super.initState();
  }

  double? _progress;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: const Key('some key here'),
      direction: DismissDirection.down,
      background: Container(color: Colors.white),
      onDismissed: (_) => Navigator.pop(context),
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          return WillPopScope(
            onWillPop: () {
              Navigator.pop(context);
              return Future.value(false);
            },
            child: Scaffold(
                floatingActionButton: widget.isAsset == true
                    ? null
                    : FloatingActionButton(
                        onPressed: () async {
                          _progress != null
                              ? null
                              : FileDownloader.downloadFile(
                                  name: 'Cheebo${DateTime.now()}.jpg',
                                  url: widget.image!.trim(),
                                  onProgress: (fileName, progress) {
                                    setState(() {
                                      _progress = progress;
                                    });
                                  },
                                  onDownloadCompleted: (path) {
                                    setState(() {
                                      _progress = null;
                                    });
                                    flutterToast(
                                        msg: ' image is saved to gallary');
                                  },
                                );
                        },
                        backgroundColor: Colors.red,
                        child: _progress != null
                            ? CircularProgressIndicator(
                                backgroundColor: Colors.red,
                                color: Colors.red,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                                value: (_progress ?? 0) > 100
                                    ? 0
                                    : ((_progress ?? 0) % 100) / 100,
                              )
                            : const Icon(
                                Icons.download_sharp,
                                color: Colors.white,
                              ),
                      ),
                appBar: AppBar(
                    backgroundColor: Colors.transparent,
                    automaticallyImplyLeading: false,
                    actions: [
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.red,
                          )),
                    ]),
                body: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width / 32,
                    vertical: MediaQuery.of(context).size.width / 44,
                  ),
                  child: (widget.image == null || (widget.isAsset == true))
                      ? PhotoView(
                          imageProvider:
                              const AssetImage('assets/images/profile.png'),
                          backgroundDecoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          // enableRotation: true,
                          minScale: PhotoViewComputedScale.contained * 0.8,
                          maxScale: PhotoViewComputedScale.covered * 1.8,
                          initialScale: PhotoViewComputedScale.contained,
                          basePosition: Alignment.center,
                        )
                      : PhotoView(
                          imageProvider: NetworkImage(widget.image!),
                          backgroundDecoration: BoxDecoration(
                            color: Colors.red,
                          ),
                          // enableRotation: true,
                          minScale: PhotoViewComputedScale.contained * 0.8,
                          maxScale: PhotoViewComputedScale.covered * 1.8,
                          initialScale: PhotoViewComputedScale.contained,
                          basePosition: Alignment.center,
                        ),
                )),
          );
        },
      ),
    );
  }

  Future<void> saveNetworkImage(String imageUrl) async {
    // FileDownloader.downloadFile(
    //   name: 'Pexels${DateTime.now()}.jpg',
    //   url: imageUrl.trim(),
    //   onProgress: (fileName, progress) {
    //     setState(() {
    //       _progress = progress;
    //     });
    //   },
    //   onDownloadCompleted: (path) {
    //     print('path = $path');
    //     setState(() {
    //       _progress = null;
    //     });
    //     ScaffoldMessenger.of(context).showSnackBar(
    //         const SnackBar(content: Text('image is saved to gallary')));
    //   },
    // );
  }

  Future<bool> _requestPermission() async {
    if (Platform.isIOS) {
      // Permissions are automatically handled on iOS
      return true;
    } else if (Platform.isAndroid) {
      if (await Permission.storage.isGranted) {
        // Permission is already granted
        return true;
      } else if (await Permission.storage.isDenied) {
        // Request permission if denied
        var result = await Permission.storage.request();
        return result.isGranted;
      } else if (await Permission.storage.isPermanentlyDenied) {
        // If permanently denied, open settings
        await openAppSettings();
        return false;
      }

      // For Android 13+ (API level 33+)
      var photosPermission = await Permission.photos.status;
      if (photosPermission.isDenied) {
        photosPermission = await Permission.photos.request();
        return photosPermission.isGranted;
      } else if (photosPermission.isPermanentlyDenied) {
        await openAppSettings();
        return false;
      }
    }
    return false;
  }
}
