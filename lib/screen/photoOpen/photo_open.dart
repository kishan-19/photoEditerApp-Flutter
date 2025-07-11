import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:photoediter/screen/photoOpen/photo_open_Provider.dart';
import '../home/home_provider.dart';

class PhotoOpen extends StatefulWidget {
  final int photoIndex;

  const PhotoOpen({super.key, required this.photoIndex});

  @override
  State<PhotoOpen> createState() => _PhotoOpenState();
}

class _PhotoOpenState extends State<PhotoOpen> {
  @override
  void initState() {
    super.initState();
    context.read<HomeProvider>().changeValueOfDropdown(context.read<HomeProvider>().photos[widget.photoIndex]['mime']);
    Future.delayed(Duration.zero, () {
      context.read<PhotoOpenProvider>().toggler(const Duration(seconds: 5));
    });
  }

  @override
  Widget build(BuildContext context) {
    final photoFile = context.read<HomeProvider>().photos[widget.photoIndex];
    final isVisible = context.watch<PhotoOpenProvider>().isVisible;

    return Scaffold(
      appBar: AppBar(title: const Text('View Photo')),
      body: GestureDetector(
        onTap: () {
          context.read<PhotoOpenProvider>().toggler(const Duration(seconds: 5));
        },
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: InteractiveViewer(
                panEnabled: true, // Can move image
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.file(
                  File(photoFile['image']),
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Floating BottomNavigationBar
            if (isVisible)
              Positioned(
                left: 16,
                right: 16,
                bottom: 10,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: isVisible ? 1 : 0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [

                        TextButton.icon(
                          onPressed: () {
                              context.read<HomeProvider>().editeImage(imageindex: widget.photoIndex, context: context);
                          },
                          icon: Icon(Icons.edit, color: Colors.black),
                          label: Text("Edit", style: TextStyle(color: Colors.black)),
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
                        TextButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.table_rows, color: Colors.black),
                          label: Text("Details", style: TextStyle(color: Colors.black)),
                        ),

                        TextButton.icon(
                          onPressed: () {
                            context.read<PhotoOpenProvider>().sImageToGallery(photoFile['image'],photoFile['mime'],context);
                          },
                          icon: Icon(Icons.save_alt, color: Colors.black),
                          label: Text("Save", style: TextStyle(color: Colors.black)),
                        ),
                      ],
                    ),
                  ),

                ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
