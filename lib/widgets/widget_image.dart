import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MarkerImage extends StatefulWidget {
  final bool isDarkTheme;

  const MarkerImage({super.key, required this.isDarkTheme});

  @override
  State<MarkerImage> createState() => _MarkerImageState();
}

class _MarkerImageState extends State<MarkerImage> {
  Uint8List? imageData;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    String path = widget.isDarkTheme
        ? 'assets/gifs/icon-driver2.gif'
        : 'assets/gifs/icon-driver1.png';

    final ByteData data = await rootBundle.load(path);
    setState(() {
      imageData = data.buffer.asUint8List();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (imageData == null) {
      return const SizedBox(width: 80, height: 80); // Espacio en blanco mientras carga
    }

    return RepaintBoundary(
      child: Image.memory(imageData!, width: 80, height: 80),
    );
  }
}
