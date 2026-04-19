import 'package:flutter/material.dart';

class StoryProgressBar extends StatelessWidget {
  final int totalStories;
  final int currentIndex;
  final Animation<double> animation;

  const StoryProgressBar({
    required this.totalStories,
    required this.currentIndex,
    required this.animation,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalStories, (i) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: _SingleBar(
              filled: i < currentIndex,
              isCurrent: i == currentIndex,
              animation: animation,
            ),
          ),
        );
      }),
    );
  }
}

class _SingleBar extends StatelessWidget {
  final bool filled;
  final bool isCurrent;
  final Animation<double> animation;

  const _SingleBar({required this.filled, required this.isCurrent, required this.animation});

  @override
  Widget build(BuildContext context) {
    if (!isCurrent) {
      return LinearProgressIndicator(
        value: filled ? 1.0 : 0.0,
        minHeight: 3,
        backgroundColor: Colors.white38,
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
      );
    }
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) => LinearProgressIndicator(
        value: animation.value,
        minHeight: 3,
        backgroundColor: Colors.white38,
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }
}
