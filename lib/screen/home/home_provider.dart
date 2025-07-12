import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photoediter/service/hive_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeProvider extends ChangeNotifier {
  File? galleryFile;
  final ImagePicker picker = ImagePicker();
  List<Map<String, dynamic>> photos = [];

  // selection Image
  List<Map<String, dynamic>> isSelect = [];
  bool selectionMode = false;

  List<String> list = ['jpeg', 'png', 'jpg'];
  String dropdownValue = 'jpeg';

  void changeValueOfDropdown(String value) {
    dropdownValue = value;
    notifyListeners();
  }
// share images
  Future<void> shareImage() async {
    final List<XFile> files = [];

    for (final path in isSelect) {
      final file = File(path['image']);
      if (await file.exists()) {
        files.add(XFile(file.path));
      } else {
        debugPrint("⚠️ File not found: $path");
      }
    }
    if (files.isNotEmpty) {
      await Share.shareXFiles(
        files,
        // text: text ?? "Check these out!",
      );
    } else {
      debugPrint("❌ No valid image files to share");
    }
  }

  //load data to hive

  void loadDataToHive(){
    final raw = HiveService.box.get("mapList");

    if(raw != null){
      final decoded = jsonDecode(raw);
      photos =List<Map<String,dynamic>>.from(decoded);
      notifyListeners();
      debugPrint("✅ Loaded stored images");
    }
  }

//hive database add data
//   void addData(Map<String,dynamic> item){
//       photos.add(item);
//       saveToHive();
//   }

  void saveToHive(){
    final encode = jsonEncode(photos);
    HiveService.box.put("mapList", encode);
    notifyListeners();
  }

  // void clearData() {
  //   photos.clear();
  //   _saveToHive();
  // }


  // Load data when app starts
  // Future<void> loadData() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final jsonString = prefs.getString('storedData');
  //
  //   if (jsonString != null && jsonString.isNotEmpty) {
  //     try {
  //       final decoded = jsonDecode(jsonString) as List;
  //       photos = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  //       notifyListeners();
  //       debugPrint("✅ Loaded stored images");
  //     } catch (e) {
  //       debugPrint("❌ Load failed: $e");
  //     }
  //   }
  // }


  // Save data when app is closed
  // Future<void> saveData() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final jsonString = jsonEncode(photos);
  //   await prefs.setString('storedData', jsonString);
  //   debugPrint("💾 Photos saved");
  // }


//select Images
  void addSelectValue(int indexvalue) {
    if (isSelect.map((element)=>element['image']).contains(photos[indexvalue]['image'])) {
      isSelect.removeWhere((element) => element['image'] == photos[indexvalue]['image']);
      notifyListeners();
    } else {
      selectionMode = true;
      isSelect.add(photos[indexvalue]);
      print(isSelect);
      notifyListeners();
    }
  }

  void offSelectionMode() {
    selectionMode = false;
    isSelect.clear();
    notifyListeners();
  }

  void delectImage() {
    for(Map map in isSelect){
      photos.removeWhere((element) => element['image'] == map['image']);
    }
    // saveData();
    notifyListeners();
  }

  //edite image
  Future<void> editeImage({
    required int imageindex,
    required BuildContext context,
  }) async {
    try {
      String photo = photos[imageindex]['image'];

      final cropped = await ImageCropper().cropImage(
        sourcePath: photo,
        compressFormat: dropdownValue == 'png' ? ImageCompressFormat.png : ImageCompressFormat.jpg,
        compressQuality: 100,

        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.deepPurple,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
          IOSUiSettings(title: 'Crop Image'),
        ],
      );
      if (cropped != null) {
        final tempImage = File(cropped.path);

        getImageInfo(tempImage).then((image) async {
          print('📏 Image size: ${image.width} × ${image.height} pixels');

          final dir = await _getImagesDirectory();
          final fileName = '${DateTime.now().millisecondsSinceEpoch}${dropdownValue == 'png' ? '.png': '.jpg'}';
          final savedImage = await tempImage.copy('${dir.path}/$fileName');
          print(
            "---dir ${dir} filename ${fileName} saveimage ${savedImage} temname ${tempImage}",
          );

          galleryFile = tempImage;
          photos.removeAt(imageindex);
          photos.insert(imageindex, {
            "image": savedImage.path,
            "pixels": '${image.width} × ${image.height} pix/${dropdownValue}',
            "mime":dropdownValue,
            "imageName": fileName,
          });
          // saveData();
          notifyListeners();
          Navigator.pop(context);
        });
      } else {
        final tempImage = File(photo);

        getImageInfo(tempImage).then((image) async {
          print('📏 Image size: ${image.width} × ${image.height} pixels');

          final dir = await _getImagesDirectory();
          final fileName = '${DateTime.now().millisecondsSinceEpoch}${dropdownValue == 'png' ? '.png': '.jpg'}';
          final savedImage = await tempImage.copy('${dir.path}/$fileName');
          print(
            "---dir ${dir} filename ${fileName} saveimage ${savedImage} temname ${tempImage}",
          );

          galleryFile = tempImage;
          photos.removeAt(imageindex);
          photos.insert(imageindex, {
            "image": savedImage.path,
            "pixels": '${image.width} × ${image.height} pix/${dropdownValue}',
            "mime":dropdownValue,
            "imageName": fileName,
          });
          // saveData();
          notifyListeners();
          Navigator.pop(context);
        });
      }
    } catch (e) {
      debugPrint(e.toString());
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Crop failed: $e')));
    }
  }


  // select image
  Future<void> pickImage(ImageSource src, BuildContext context) async {
    try {
      final photo = await ImagePicker().pickImage(source: src);
      if (photo == null) return;

      final cropped = await ImageCropper().cropImage(
        sourcePath: photo.path,
        compressFormat: dropdownValue == 'png' ? ImageCompressFormat.png : ImageCompressFormat.jpg,
        compressQuality: 100,

        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.deepPurple,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
          IOSUiSettings(title: 'Crop Image'),
        ],
      );
      if (cropped != null) {
        final tempImage = File(cropped.path);

        getImageInfo(tempImage).then((image) async {
          print('📏 Image size: ${image.width} × ${image.height} pixels');

          final dir = await _getImagesDirectory();
          final fileName = '${DateTime.now().millisecondsSinceEpoch}${dropdownValue == 'png' ? '.png': '.jpg'}';
          final savedImage = await tempImage.copy('${dir.path}/$fileName');
          print(
            "---dir ${dir} filename ${fileName} saveimage ${savedImage} temname ${tempImage}",
          );

          galleryFile = tempImage;
          photos.add({
            "image": savedImage.path,
            "pixels": '${image.width} × ${image.height} pix/${dropdownValue}',
            "imageName": fileName,
            "mime":dropdownValue
          });
          // saveData();
          notifyListeners();
        });
      } else {
        final tempImage = File(photo.path);

        getImageInfo(tempImage).then((image) async {
          print('📏 Image size: ${image.width} × ${image.height} pixels');

          final dir = await _getImagesDirectory();
          final fileName = '${DateTime.now().millisecondsSinceEpoch}${dropdownValue == 'png' ? '.png': '.jpg'}';
          final savedImage = await tempImage.copy('${dir.path}/$fileName');
          print(
            "---dir ${dir} filename ${fileName} saveimage ${savedImage} temname ${tempImage}",
          );

          galleryFile = tempImage;
          photos.add({
            "image": savedImage.path,
            "pixels": '${image.width} × ${image.height} pix/${dropdownValue}',
            "mime":dropdownValue,
            "imageName": fileName,
          });
          // saveData();
          notifyListeners();
        });
      }
    } catch (e) {
      debugPrint(e.toString());
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Crop failed: $e')));
    }
  }

  // get image pix
  Future<ui.Image> getImageInfo(File imageFile) async {
    final data = await imageFile.readAsBytes();
    final codec = await ui.instantiateImageCodec(data);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  //ge image folder
  Future<Directory> _getImagesDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${appDir.path}/photos');
    if (!(await imagesDir.exists())) {
      await imagesDir.create(recursive: true);
    }
    return imagesDir;
  }
}
