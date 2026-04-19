import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/storie_model.dart';

class StorieThumbnail extends StatelessWidget {
  final StorieModel storie;
  final VoidCallback? onTap;

  /// Chamado quando o usuário toca no botão "+" do próprio story.
  final VoidCallback? onAddStory;

  /// Cor do anel de "não visto". Padrão: gradiente laranja/roxo do Instagram.
  final Color? unviewedRingColor;

  const StorieThumbnail({
    required this.storie,
    this.onTap,
    this.onAddStory,
    this.unviewedRingColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final hasUnviewed = storie.hasUnviewed ?? false;
    final isOwn = storie.isOwn ?? false;
    final label = isOwn ? 'Seu Story' : (storie.username ?? '');

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                _AvatarRing(
                  avatarUrl: storie.avatar,
                  hasUnviewed: hasUnviewed,
                  ringColor: unviewedRingColor,
                ),
                if (isOwn)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: onAddStory,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 14),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarRing extends StatelessWidget {
  final String? avatarUrl;
  final bool hasUnviewed;
  final Color? ringColor;

  const _AvatarRing({
    required this.avatarUrl,
    required this.hasUnviewed,
    this.ringColor,
  });

  @override
  Widget build(BuildContext context) {
    const avatarRadius = 28.0;
    const ringWidth = 2.5;
    const gap = 2.0;

    Widget avatar = CircleAvatar(
      radius: avatarRadius,
      backgroundImage: (avatarUrl?.isNotEmpty ?? false) ? CachedNetworkImageProvider(avatarUrl!) : null,
      backgroundColor: Colors.grey[300],
      child: (avatarUrl?.isEmpty ?? true) ? const Icon(Icons.person, size: 28) : null,
    );

    if (!hasUnviewed) return avatar;

    final color = ringColor ?? const Color(0xFFE1306C);

    return Container(
      padding: const EdgeInsets.all(gap),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: ringColor != null
            ? null
            : const LinearGradient(
                colors: [Color(0xFFF58529), Color(0xFFDD2A7B), Color(0xFF8134AF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: ringColor != null ? color : null,
        border: Border.all(
          color: Colors.transparent,
          width: ringWidth,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(gap),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: avatar,
      ),
    );
  }
}
