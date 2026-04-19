# seven_story_viewer

Package exclusivo do aplicativo **Atleta do Vôlei**. Não é publicado no pub.dev e não se destina a uso externo — faz parte da composição interna do projeto.

Fornece o visualizador de stories com suporte a imagem, vídeo e texto.

## Funcionalidades

- Exibição de stories em tela cheia com paginação horizontal entre usuários
- Suporte a três tipos de conteúdo: `image`, `video` e `text`
- Barra de progresso animada por story
- Pré-carregamento do próximo vídeo
- Pause/resume por long press
- Curtir/descurtir com animação (estado gerenciado internamente)
- Campo de comentário com pause/resume automático do story ao focar
- Callbacks opcionais para registrar visualização, curtida e comentário no backend

## Uso

```dart
import 'package:story_viewer/story_viewer.dart';

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => StoryViewerPage(
      userGroups: stories,           // List<StorieModel>
      initialUserIndex: 0,
      onStoryView: (id) => repo.registerView(id),          // opcional
      onLike: (id, {required liked}) => repo.like(id, liked), // opcional
      onComment: (id, comment) => repo.postComment(id, comment), // opcional
    ),
  ),
);
```

## Modelos

```dart
// Grupo de stories de um usuário
StorieModel(
  id: 1,
  username: 'Renato Veiga',
  avatar: 'https://...',
  stories: [
    StoryModel(id: 10, mediaUrl: 'https://...'),                  // imagem
    StoryModel(id: 11, type: StoryType.video, mediaUrl: 'https://...'), // vídeo
    StoryModel(                                                    // texto
      id: 12,
      type: StoryType.text,
      text: 'Treino incrível hoje!',
      backgroundColor: Color(0xFF3C5198),
      fontSize: 28,
    ),
  ],
);
```

## Dependências

- [`video_player`](https://pub.dev/packages/video_player)
- [`cached_network_image`](https://pub.dev/packages/cached_network_image)
