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

  StoryModel({
    this.id = 0,
    this.type = StoryType.image,
    this.mediaUrl,
    this.text,
    this.backgroundColor = Colors.black,
    this.textColor = Colors.white,
    this.fontSize = 24,
    this.duration = const Duration(seconds: 5),
  });

  StoryModel.fromJson(Map<String, dynamic> json)
      : id = 0,
        type = StoryType.image,
        backgroundColor = Colors.black,
        textColor = Colors.white,
        fontSize = 24,
        duration = const Duration(seconds: 5) {
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
  }

  static int? _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '');
  }

  static double? _parseDouble(dynamic v) {
    if (v is double) return v;
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '');
  }
}
