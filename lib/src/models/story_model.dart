import 'package:flutter/material.dart';

enum StoryType { image, video, text }

class StoryModel {
  int id;
  StoryType type;
  String? mediaUrl;
  String? text;
  Color backgroundColor;
  Color textColor;
  double fontSize;
  Duration duration;
  bool isLiked;
  bool isViewed;
  int likesCount;
  int commentsCount;
  int viewsCount;

  StoryModel({
    this.id = 0,
    this.type = StoryType.image,
    this.mediaUrl,
    this.text,
    this.backgroundColor = Colors.black,
    this.textColor = Colors.white,
    this.fontSize = 24,
    this.duration = const Duration(seconds: 5),
    this.isLiked = false,
    this.isViewed = false,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.viewsCount = 0,
  });

  StoryModel.fromJson(Map<String, dynamic> json)
      : id = 0,
        type = StoryType.image,
        backgroundColor = Colors.black,
        textColor = Colors.white,
        fontSize = 24,
        duration = const Duration(seconds: 5),
        isLiked = false,
        isViewed = false,
        likesCount = 0,
        commentsCount = 0,
        viewsCount = 0 {
    id = _parseInt(json['id']) ?? 0;
    type = StoryType.values.firstWhere(
      (e) => e.name == (json['type']?.toString() ?? ''),
      orElse: () => StoryType.image,
    );
    mediaUrl = json['media_url']?.toString();
    text = json['text']?.toString();
    final bgInt = json['background_color'];
    if (bgInt != null) {
      backgroundColor = Color(int.tryParse(bgInt.toString()) ?? 0xFF000000);
    }
    final tcInt = json['text_color'];
    if (tcInt != null) {
      textColor = Color(int.tryParse(tcInt.toString()) ?? 0xFFFFFFFF);
    }
    fontSize = _parseDouble(json['font_size']) ?? 24.0;
    duration = Duration(seconds: _parseInt(json['duration']) ?? 5);
    isLiked = _parseBool(json['is_liked']) ?? false;
    isViewed = _parseBool(json['is_viewed']) ?? false;
    likesCount = _parseInt(json['likes_count']) ?? 0;
    commentsCount = _parseInt(json['comments_count']) ?? 0;
    viewsCount = _parseInt(json['views_count']) ?? 0;
  }

  static int? _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '');
  }

  static bool? _parseBool(dynamic v) {
    if (v is bool) return v;
    final s = v?.toString().toLowerCase();
    if (s == 'true') return true;
    if (s == 'false') return false;
    return null;
  }

  static double? _parseDouble(dynamic v) {
    if (v is double) return v;
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '');
  }
}
