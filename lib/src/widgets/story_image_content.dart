import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/story_model.dart';

class StoryImageContent extends StatelessWidget {
  final StoryModel story;

  const StoryImageContent({required this.story, super.key});

  @override
  Widget build(BuildContext context) {
    final url = story.mediaUrl;
    if (url == null || url.isEmpty) {
      return const ColoredBox(color: Colors.black);
    }
    return SizedBox.expand(
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (_, __) => const ColoredBox(color: Colors.black),
        errorWidget: (_, __, ___) => const ColoredBox(color: Colors.black),
      ),
    );
  }
}
