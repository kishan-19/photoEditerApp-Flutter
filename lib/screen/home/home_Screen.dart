import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photoediter/screen/home/home_provider.dart';
import 'package:photoediter/screen/photoOpen/photo_open.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>{
  final _key = GlobalKey<ExpandableFabState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<HomeProvider>().loadData();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<HomeProvider>().offSelectionMode(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Photo Editor'),

          actions: [
            Consumer<HomeProvider>(
              builder: (_, Provider, __) {
                return Provider.isSelect.isNotEmpty
                    ? GestureDetector(
                  onTap: () {
                    context.read<HomeProvider>().shareImage();
                  },
                  child: Icon(Icons.share_outlined),
                )
                    : SizedBox.shrink();
              },
            ),
            SizedBox(width: 10,),
            Consumer<HomeProvider>(
              builder: (_, Provider, __) {
                return Provider.isSelect.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          context.read<HomeProvider>().delectImage();
                          context.read<HomeProvider>().offSelectionMode();
                        },
                        child: Icon(Icons.delete),
                      )
                    : SizedBox.shrink();
              },
            ),
          ],
          actionsPadding: EdgeInsets.all(16),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Consumer<HomeProvider>(
              builder: (_, Provider, __) {
                if (Provider.photos.isEmpty) {
                  return Center(
                    child: Text(
                      "Image not found",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                } else {
                  return GridView.builder(
                    shrinkWrap: true,
                    itemCount: Provider.photos.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                    ),
                    itemBuilder: (_, index) {
                      return GestureDetector(
                        onLongPress: () {
                          context.read<HomeProvider>().addSelectValue(index);
                        },
                        onTap: () => {
                          Provider.selectionMode
                              ? context.read<HomeProvider>().addSelectValue(
                                  index,
                                )
                              : Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PhotoOpen(photoIndex: index),
                                  ),
                                ),
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Provider.isSelect.map((element)=>element['image']).contains(Provider.photos[index]['image'])
                                ? Border.all(color: Colors.blue, width: 2)
                                : null,
                          ),
                          child: Stack(
                            children: [
                              Image.file(
                                File(Provider.photos[index]['image']),
                                fit: BoxFit.cover,
                                width: 100,
                              ),
                              Positioned(
                                bottom: 0,
                                child: Container(
                                  width: 80,
                                  child: Text(
                                    Provider.photos[index]['pixels'],
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ),

        floatingActionButtonLocation: ExpandableFab.location,
        floatingActionButton: ExpandableFab(
          key: _key,
          type: ExpandableFabType.up,
          childrenAnimation: ExpandableFabAnimation.none,
          distance: 60,

          overlayStyle: ExpandableFabOverlayStyle(
            color: Colors.white.withOpacity(0.9),
          ),

          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: GestureDetector(
                onTap: () {
                  context.read<HomeProvider>().pickImage(
                    ImageSource.camera,
                    context,
                  );
                },
                child: Row(
                  spacing: 8,
                  children: [Text('Camera'), Icon(Icons.camera_alt_outlined)],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                context.read<HomeProvider>().pickImage(
                  ImageSource.gallery,
                  context,
                );
                // Navigator.pop(context);
              },
              child: Row(
                spacing: 8,
                children: [
                  Text('Gallery '),
                  Icon(Icons.photo_library_outlined),
                ],
              ),
            ),
            Consumer<HomeProvider>(
              builder: (_, Provider, __) {
                return DropdownButton<String>(
                  value: Provider.dropdownValue,
                  icon: const Icon(Icons.arrow_downward),
                  style: const TextStyle(color: Colors.black),
                  elevation: 16,
                  underline: Container(height: 2, color: Colors.black),
                  onChanged: (String? value) {
                    context.read<HomeProvider>().changeValueOfDropdown(value!);
                  },
                  items: Provider.list.map<DropdownMenuItem<String>>((
                    String value,
                  ) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
