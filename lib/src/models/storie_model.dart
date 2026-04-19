import 'story_model.dart';

class StorieModel {
  int? id;
  String? username;
  String? avatar;
  bool? isOwn;
  List<StoryModel> stories;

  StorieModel({
    this.id,
    this.username,
    this.avatar,
    this.isOwn,
    this.stories = const [],
  });

  StorieModel.fromJson(Map<String, dynamic> json) : stories = [] {
    id = _parseInt(json['id']);
    username = json['username']?.toString();
    avatar = json['avatar']?.toString();
    isOwn = _parseBool(json['is_own']);
    final storiesJson = json['stories'];
    if (storiesJson is List) {
      stories = storiesJson
          .whereType<Map<String, dynamic>>()
          .map(StoryModel.fromJson)
          .toList();
    }
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
}
