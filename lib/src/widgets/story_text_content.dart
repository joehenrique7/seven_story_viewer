import 'package:flutter/material.dart';

import '../models/story_model.dart';

class StoryTextContent extends StatelessWidget {
  final StoryModel story;

  const StoryTextContent({required this.story, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: story.backgroundColor,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(32),
      child: Text(
        story.text ?? '',
        textAlign: TextAlign.center,
        maxLines: 10,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: story.fontSize,
          color: story.textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
