import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/storie_model.dart';
import '../models/story_model.dart';
import '../store/story_viewer_store.dart';
import 'story_image_content.dart';
import 'story_progress_bar.dart';
import 'story_text_content.dart';
import 'story_video_content.dart';

class StoryViewerPage extends StatefulWidget {
  final List<StorieModel> userGroups;
  final int initialUserIndex;

  /// Chamado quando um story se torna ativo (registrar visualização).
  final Future<void> Function(int storyId)? onStoryView;

  /// Chamado ao curtir ou descurtir. [liked] indica o novo estado.
  final Future<void> Function(int storyId, {required bool liked})? onLike;

  /// Chamado ao enviar um comentário.
  final Future<void> Function(int storyId, String comment)? onComment;

  /// Ícone do botão de enviar comentário. Padrão: [Icons.send_rounded].
  final IconData sendIcon;

  /// Ícone exibido quando o story está curtido. Padrão: [Icons.favorite].
  final IconData likedIcon;

  /// Ícone exibido quando o story não está curtido. Padrão: [Icons.favorite_border].
  final IconData unlikedIcon;

  /// Ícone do botão de fechar. Padrão: [Icons.close].
  final IconData closeIcon;

  /// Texto placeholder do campo de comentário. Padrão: 'Adicionar comentário...'.
  final String commentHintText;

  const StoryViewerPage({
    required this.userGroups,
    required this.initialUserIndex,
    this.onStoryView,
    this.onLike,
    this.onComment,
    this.sendIcon = Icons.send_rounded,
    this.likedIcon = Icons.favorite,
    this.unlikedIcon = Icons.favorite_border,
    this.closeIcon = Icons.close,
    this.commentHintText = 'Adicionar comentário...',
    super.key,
  });

  @override
  State<StoryViewerPage> createState() => _StoryViewerPageState();
}

class _StoryViewerPageState extends State<StoryViewerPage> with TickerProviderStateMixin {
  late final StoryViewerStore _store;
  late final PageController _pageController;
  late final Set<int> _likedIds;

  @override
  void initState() {
    super.initState();
    _likedIds = {
      for (final group in widget.userGroups)
        for (final story in group.stories)
          if (story.isLiked) story.id,
    };
    _store = StoryViewerStore(onStoryView: widget.onStoryView);
    _pageController = PageController(initialPage: widget.initialUserIndex);

    _store.onGroupExhausted = (forward) {
      if (!mounted) return;
      final currentPage = _pageController.page?.round() ?? widget.initialUserIndex;
      if (forward) {
        if (currentPage < widget.userGroups.length - 1) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else {
          Navigator.of(context).pop();
        }
      } else {
        if (currentPage > 0) {
          _pageController.previousPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else {
          Navigator.of(context).pop();
        }
      }
    };

    _store.init(this, widget.userGroups, widget.initialUserIndex);
  }

  void _toggleLike(int storyId) {
    final nowLiked = !_likedIds.contains(storyId);
    setState(() {
      if (nowLiked) {
        _likedIds.add(storyId);
      } else {
        _likedIds.remove(storyId);
      }
    });
    widget.onLike?.call(storyId, liked: nowLiked);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.userGroups.length,
        onPageChanged: (index) => _store.setUserGroup(index),
        itemBuilder: (context, index) {
          return ListenableBuilder(
            listenable: _store,
            builder: (context, _) {
              if (index != _store.currentUserIndex) {
                return const ColoredBox(color: Colors.black);
              }
              return _UserStoryPage(
                store: _store,
                group: widget.userGroups[index],
                likedIds: _likedIds,
                onToggleLike: _toggleLike,
                onComment: widget.onComment,
                sendIcon: widget.sendIcon,
                likedIcon: widget.likedIcon,
                unlikedIcon: widget.unlikedIcon,
                closeIcon: widget.closeIcon,
                commentHintText: widget.commentHintText,
              );
            },
          );
        },
      ),
    );
  }
}

// ── _UserStoryPage ────────────────────────────────────────────────────────────

class _UserStoryPage extends StatefulWidget {
  final StoryViewerStore store;
  final StorieModel group;
  final Set<int> likedIds;
  final void Function(int storyId) onToggleLike;
  final Future<void> Function(int storyId, String comment)? onComment;
  final IconData sendIcon;
  final IconData likedIcon;
  final IconData unlikedIcon;
  final IconData closeIcon;
  final String commentHintText;

  const _UserStoryPage({
    required this.store,
    required this.group,
    required this.likedIds,
    required this.onToggleLike,
    required this.sendIcon,
    required this.likedIcon,
    required this.unlikedIcon,
    required this.closeIcon,
    required this.commentHintText,
    this.onComment,
  });

  @override
  State<_UserStoryPage> createState() => _UserStoryPageState();
}

class _UserStoryPageState extends State<_UserStoryPage> {
  late final FocusNode _focusNode;
  late final TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _commentController = TextEditingController();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      widget.store.pause();
    } else {
      widget.store.resume();
    }
  }

  void _submitComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    widget.onComment?.call(widget.store.currentStory.id, text);
    _commentController.clear();
    _focusNode.unfocus();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Conteúdo do story
        ListenableBuilder(
          listenable: widget.store,
          builder: (context, _) => _StoryContent(store: widget.store),
        ),

        // Área de gestos (tap/long press) — exclui os últimos 80px (bottom bar)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 80,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTapUp: (details) {
              final screenWidth = MediaQuery.of(context).size.width;
              if (details.globalPosition.dx < screenWidth / 2) {
                widget.store.goToPreviousStory();
              } else {
                widget.store.goToNextStory();
              }
            },
            onLongPressStart: (_) => widget.store.pause(),
            onLongPressEnd: (_) => widget.store.resume(),
            onLongPressCancel: () => widget.store.resume(),
          ),
        ),

        // Gradiente superior para legibilidade do header
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 180,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.55),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Gradiente inferior para legibilidade da barra de comentário/like
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 160,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.55),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Header (progress bar + avatar + fechar)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListenableBuilder(
                    listenable: widget.store,
                    builder: (context, _) {
                      final animation = widget.store.animationController;
                      if (animation == null) return const SizedBox(height: 3);
                      return StoryProgressBar(
                        totalStories: widget.group.stories.length,
                        currentIndex: widget.store.currentStoryIndex,
                        animation: animation,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  ListenableBuilder(
                    listenable: widget.store,
                    builder: (context, _) => _StoryHeader(
                      group: widget.store.currentGroup,
                      closeIcon: widget.closeIcon,
                      onClose: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Barra inferior (comentário + like)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: ListenableBuilder(
            listenable: widget.store,
            builder: (context, _) => _StoryBottomBar(
              storyId: widget.store.currentStory.id,
              isLiked: widget.likedIds.contains(widget.store.currentStory.id),
              focusNode: _focusNode,
              controller: _commentController,
              onToggleLike: widget.onToggleLike,
              onSubmitComment: _submitComment,
              sendIcon: widget.sendIcon,
              likedIcon: widget.likedIcon,
              unlikedIcon: widget.unlikedIcon,
              commentHintText: widget.commentHintText,
            ),
          ),
        ),
      ],
    );
  }
}

// ── _StoryBottomBar ───────────────────────────────────────────────────────────

class _StoryBottomBar extends StatelessWidget {
  final int storyId;
  final bool isLiked;
  final FocusNode focusNode;
  final TextEditingController controller;
  final void Function(int storyId) onToggleLike;
  final VoidCallback onSubmitComment;
  final IconData sendIcon;
  final IconData likedIcon;
  final IconData unlikedIcon;
  final String commentHintText;

  const _StoryBottomBar({
    required this.storyId,
    required this.isLiked,
    required this.focusNode,
    required this.controller,
    required this.onToggleLike,
    required this.onSubmitComment,
    required this.sendIcon,
    required this.likedIcon,
    required this.unlikedIcon,
    required this.commentHintText,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                focusNode: focusNode,
                controller: controller,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                cursorColor: Colors.white,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSubmitComment(),
                decoration: InputDecoration(
                  hintText: commentHintText,
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  suffixIcon: IconButton(
                    icon: Icon(sendIcon, color: Colors.white, size: 20),
                    onPressed: onSubmitComment,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => onToggleLike(storyId),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: child,
                ),
                child: Icon(
                  isLiked ? likedIcon : unlikedIcon,
                  key: ValueKey(isLiked),
                  color: isLiked ? Colors.red : Colors.white,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── _StoryContent ─────────────────────────────────────────────────────────────

class _StoryContent extends StatelessWidget {
  final StoryViewerStore store;

  const _StoryContent({required this.store});

  @override
  Widget build(BuildContext context) {
    if (store.currentGroup.stories.isEmpty) {
      return const ColoredBox(color: Colors.black);
    }

    final story = store.currentStory;
    return switch (story.type) {
      StoryType.image => StoryImageContent(story: story),
      StoryType.text => StoryTextContent(story: story),
      StoryType.video => store.videoController?.value.isInitialized == true
          ? StoryVideoContent(controller: store.videoController!)
          : const ColoredBox(
              color: Colors.black,
              child: Center(
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              ),
            ),
    };
  }
}

// ── _StoryHeader ──────────────────────────────────────────────────────────────

class _StoryHeader extends StatelessWidget {
  final StorieModel group;
  final VoidCallback onClose;
  final IconData closeIcon;

  const _StoryHeader({
    required this.group,
    required this.onClose,
    required this.closeIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundImage: (group.avatar?.isNotEmpty ?? false) ? CachedNetworkImageProvider(group.avatar!) : null,
          backgroundColor: Colors.grey[700],
          child: (group.avatar?.isEmpty ?? true) ? const Icon(Icons.person, color: Colors.white, size: 18) : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            group.username ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        GestureDetector(
          onTap: onClose,
          child: Icon(closeIcon, color: Colors.white, size: 28),
        ),
      ],
    );
  }
}
