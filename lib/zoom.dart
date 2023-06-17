import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import 'models/item.dart';

class Zoom extends StatefulWidget {
  final Item post;
  const Zoom({super.key, required this.post});

  @override
  // ignore: library_private_types_in_public_api
  Zs createState() => Zs();
}

class Zs extends State<Zoom> {
  @override
  Widget build(BuildContext context) {
    return PhotoView(
      imageProvider: NetworkImage(widget.post.mediaUrl),
    );
  }
}
