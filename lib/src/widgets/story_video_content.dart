import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class StoryVideoContent extends StatelessWidget {
  final VideoPlayerController controller;

  const StoryVideoContent({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.size.width,
          height: controller.value.size.height,
          child: VideoPlayer(controller),
        ),
      ),
    );
  }
}
