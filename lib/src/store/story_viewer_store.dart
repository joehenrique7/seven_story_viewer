import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../models/storie_model.dart';
import '../models/story_model.dart';

class StoryViewerStore extends ChangeNotifier {
  /// Optional callback called when a story becomes active (e.g. to register a view).
  final Future<void> Function(int storyId)? onStoryView;

  StoryViewerStore({this.onStoryView});

  int currentUserIndex = 0;
  int currentStoryIndex = 0;
  bool isPaused = false;
  List<StorieModel> userGroups = [];

  late TickerProvider _vsync;
  AnimationController? _animationController;
  VideoPlayerController? _videoController;
  VideoPlayerController? _nextVideoController;
  int _generation = 0;

  void Function(bool forward)? onGroupExhausted;

  StorieModel get currentGroup => userGroups[currentUserIndex];
  StoryModel get currentStory => currentGroup.stories[currentStoryIndex];
  AnimationController? get animationController => _animationController;
  VideoPlayerController? get videoController => _videoController;

  void init(TickerProvider vsync, List<StorieModel> groups, int initialUserIndex) {
    _vsync = vsync;
    userGroups = groups;
    currentUserIndex = initialUserIndex;
    currentStoryIndex = 0;
    unawaited(_startCurrentStory());
  }

  void setUserGroup(int index) {
    currentUserIndex = index;
    currentStoryIndex = 0;
    unawaited(_startCurrentStory());
  }

  void goToNextStory() {
    if (currentStoryIndex < currentGroup.stories.length - 1) {
      currentStoryIndex++;
      unawaited(_startCurrentStory());
    } else {
      onGroupExhausted?.call(true);
    }
  }

  void goToPreviousStory() {
    if (currentStoryIndex > 0) {
      currentStoryIndex--;
      unawaited(_startCurrentStory());
    } else {
      onGroupExhausted?.call(false);
    }
  }

  void pause() {
    if (isPaused) return;
    isPaused = true;
    _animationController?.stop();
    _videoController?.pause();
    notifyListeners();
  }

  void resume() {
    if (!isPaused) return;
    isPaused = false;
    _animationController?.forward();
    _videoController?.play();
    notifyListeners();
  }

  Future<void> _startCurrentStory() async {
    final gen = ++_generation;

    _disposeAnimationController();
    unawaited(_videoController?.pause() ?? Future.value());
    await _videoController?.dispose();
    _videoController = null;
    isPaused = false;

    if (userGroups.isEmpty || currentGroup.stories.isEmpty) return;

    notifyListeners();

    unawaited(onStoryView?.call(currentStory.id) ?? Future.value());

    if (currentStory.type == StoryType.video && currentStory.mediaUrl != null) {
      final url = currentStory.mediaUrl!;

      if (_nextVideoController != null && _nextVideoController!.dataSource == url) {
        _videoController = _nextVideoController;
        _nextVideoController = null;
      } else {
        _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
        await _videoController!.initialize();
      }

      if (gen != _generation) {
        unawaited(_videoController?.dispose() ?? Future.value());
        _videoController = null;
        return;
      }

      await _videoController!.play();
    }

    if (gen != _generation) return;

    Duration dur = currentStory.duration;
    if (currentStory.type == StoryType.video && _videoController != null) {
      final videoDur = _videoController!.value.duration;
      if (videoDur.inMilliseconds > 0) dur = videoDur;
    }
    if (dur.inMilliseconds <= 0) dur = const Duration(seconds: 5);

    _animationController = AnimationController(vsync: _vsync, duration: dur)
      ..addStatusListener(_onAnimationStatus);
    unawaited(_animationController!.forward());

    unawaited(_preloadNext());
    notifyListeners();
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      goToNextStory();
    }
  }

  Future<void> _preloadNext() async {
    final next = _resolveNextStory();
    if (next == null || next.type != StoryType.video || next.mediaUrl == null) return;

    await _nextVideoController?.dispose();
    _nextVideoController = VideoPlayerController.networkUrl(Uri.parse(next.mediaUrl!));
    unawaited(_nextVideoController!.initialize());
  }

  StoryModel? _resolveNextStory() {
    if (currentStoryIndex < currentGroup.stories.length - 1) {
      return currentGroup.stories[currentStoryIndex + 1];
    }
    if (currentUserIndex < userGroups.length - 1) {
      final nextGroup = userGroups[currentUserIndex + 1];
      if (nextGroup.stories.isNotEmpty) return nextGroup.stories[0];
    }
    return null;
  }

  void _disposeAnimationController() {
    _animationController?.removeStatusListener(_onAnimationStatus);
    _animationController?.dispose();
    _animationController = null;
  }

  @override
  void dispose() {
    _generation++;
    _disposeAnimationController();
    _videoController?.dispose();
    _nextVideoController?.dispose();
    super.dispose();
  }
}
