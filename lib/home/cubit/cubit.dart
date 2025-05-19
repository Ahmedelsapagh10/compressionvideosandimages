import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:light_compressor/light_compressor.dart' as LC;
import 'package:video_compress/video_compress.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../screen/show_dialog.dart';
import 'state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  List<XFile>? myImages;
  List<File>? myImagesf;
  List<File> validVideos = [];
  List<File> thumbnails = [];
  Future pickMltiImage() async {
    List<XFile>? images;
    List<File> files = [];
    try {
      images = await ImagePicker().pickMultiImage();
      if (images.isEmpty) return [];
      myImages = images;
      for (var xImage in images) {
        final file = File(xImage.path);
        // Check the image size
        final imageBytes = await file.readAsBytes();
        if (imageBytes.length > 3 * 1024 * 1024) {
          final compressedImageBytes =
              await FlutterImageCompress.compressWithFile(
            file.path,
            quality: 75,
          );
          final compressedImage = File('${file.path}.compressed.jpg');
          await compressedImage.writeAsBytes(compressedImageBytes!);
          files.add(compressedImage);
        } else {
          files.add(file);
        }
      }
    } on PlatformException catch (e) {
      debugPrint('error$e');
    }

    myImagesf = files;
    validVideos = [];

    emit(SuccessSelectNewImageState());
  }

  void deleteImage(File image) {
    myImagesf!.removeWhere((element) => element.path == image.path);
    myImages!.removeWhere((element) => element.path == image.path);
    if (myImagesf!.isEmpty) {
      myImages = null;
      myImagesf = null;
    }

    emit(SuccesRemoveImageState());
  }

  void deleteVideo(File video) {
    validVideos.removeWhere((element) => element.path == video.path);
    thumbnails.removeWhere((element) => element.path == video.path);
    if (validVideos.isEmpty) {
      validVideos = [];
    }
    emit(SuccesRemoveVideoState());
  }

  Future<List<File>?> pickMultipleVideos(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.video,
        // allowCompression: true,
      );
      if (result != null) {
        List<File> files = result.paths.map((path) => File(path!)).toList();
        //! clear List before select
        validVideos.clear();
        for (File file in files) {
          final fileBytes = await file.readAsBytes();
          if (fileBytes.length > 2 * 1024 * 1024) {
            createProgressDialog(context, 'loading');
            try {
              final thumbnailFiles = await _generateThumbnails(File(file.path));
              print('thummmmm : ${thumbnailFiles.path}');
              thumbnails.add(thumbnailFiles);
              final compressedFile = await _compressVideo(File(file.path));
              // print('video Size After : ${await compressedFile.length()}');
              validVideos.add(compressedFile);

              Navigator.pop(context);
            } catch (e) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      "Failed to compress video ${path.basename(file.path)}."),
                ),
              );
            }
            myImages = [];
            myImages = null;

            myImagesf = [];
          } else {
            createProgressDialog(context, 'loading');
            validVideos.add(File(file.path));
            Navigator.pop(context);
            myImages = [];

            myImages = null;

            myImagesf = [];
            //////////////////////
            //!

            final thumbnailFiles = await _generateThumbnails(File(file.path));
            thumbnails.add(thumbnailFiles);
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error picking videos."),
        ),
      );
      return null;
    }
    return null;
  }

//!
  Future<File> _compressVideo(File file) async {
    final LC.LightCompressor lightCompressor = LC.LightCompressor();
    final String videoName =
        'MyVideo-${DateTime.now().millisecondsSinceEpoch}.mp4';
    try {
      await VideoCompress.setLogLevel(0);
      MediaInfo videoDuration = await VideoCompress.getMediaInfo(file.path);
      // print("......${(videoDuration.duration! / 1000).round()}");

      final compressedVideo = await VideoCompress.compressVideo(
        file.path,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: true,
        includeAudio: true,
        frameRate: 15,
        startTime: 0,
        duration: (videoDuration.duration! / 1000).round() > 30
            ? (videoDuration.duration! / 1000).floor() - 30
            : 0,
      );
      final LC.Result response = await lightCompressor.compressVideo(
        path: compressedVideo!.path!,
        videoQuality: LC.VideoQuality.medium,
        isMinBitrateCheckEnabled: false,
        video: LC.Video(videoName: videoName),
        android: LC.AndroidConfig(
          isSharedStorage: false,
          saveAt: LC.SaveAt.Movies,
        ),
        ios: LC.IOSConfig(saveInGallery: false),
      );
      if (response is LC.OnSuccess) {
        return File(response.destinationPath);
      } else {
        lightCompressor.cancelCompression();
        VideoCompress.cancelCompression();
        return File('');
      }
    } catch (e) {
      lightCompressor.cancelCompression();
      VideoCompress.cancelCompression();
      return File('');
    }
  }

//? thumbnail
  Future<File> _generateThumbnails(File videoFile) async {
    print('thumbnailPath ');
    final thumbnailPath = await VideoThumbnail.thumbnailFile(
      video: videoFile.path,
      imageFormat: ImageFormat.PNG,
      quality: 100,

      timeMs: 0, // Specify the time in milliseconds to get the thumbnail from
    );

    print('thumbnailPath $thumbnailPath');
    return File(thumbnailPath!);
  }

  bool isImage = true;
  void showSelectionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(
                'pick image',
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: MediaQuery.of(context).size.width / 20),
              ),
              onTap: () async {
                // Call your pickMultiImage method here
                await pickMltiImage();
                isImage = true;

                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library),
              title: Text(
                'pick video',
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: MediaQuery.of(context).size.width / 20),
              ),
              onTap: () async {
                isImage = false;
                // Call your pickVideo method here
                final pickedVideo = await pickMultipleVideos(context);
                if (pickedVideo != null) {}

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
