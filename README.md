# seven_story_viewer

Package exclusivo do aplicativo **Atleta do Vôlei**. Não é publicado no pub.dev e não se destina a uso externo — faz parte da composição interna do projeto.

Fornece o visualizador de stories com suporte a imagem, vídeo e texto, além do widget de thumbnail para a lista horizontal.

## Fluxo de uso

```
[StorieThumbnail]  →  usuário toca  →  [StoryViewerPage]
  lista de bubbles                        tela cheia
```

**`StorieThumbnail`** exibe o avatar/nome na lista horizontal. Ao tocar, você abre o **`StoryViewerPage`** passando o índice do grupo selecionado.

## Funcionalidades

### StorieThumbnail
- Avatar circular com nome do usuário abaixo
- Anel gradiente (laranja → roxo) quando `hasUnviewed: true`
- Label "Seu Story" e botão `+` quando `isOwn: true`
- Callback `onAddStory` para o botão `+`

### StoryViewerPage
- Exibição de stories em tela cheia com paginação horizontal entre usuários
- Suporte a três tipos de conteúdo: `image`, `video` e `text`
- Barra de progresso animada por story
- Pré-carregamento do próximo vídeo
- Pause/resume por long press
- Curtir/descurtir com animação (estado gerenciado internamente)
- Campo de comentário com pause/resume automático do story ao focar
- Gradientes automáticos no topo e na base para garantir legibilidade sobre qualquer imagem
- Callbacks opcionais para registrar visualização, curtida e comentário no backend
- Ícones e placeholder do campo de comentário customizáveis via parâmetros opcionais

## Uso

### Lista horizontal de thumbnails

```dart
import 'package:story_viewer/story_viewer.dart';

ListView.builder(
  scrollDirection: Axis.horizontal,
  itemCount: stories.length,
  itemBuilder: (context, index) => StorieThumbnail(
    storie: stories[index],
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StoryViewerPage(
          userGroups: stories,
          initialUserIndex: index,
          onStoryView: (id) => repo.registerView(id),
          onLike: (id, {required liked}) => repo.like(id, liked),
          onComment: (id, comment) => repo.postComment(id, comment),
        ),
      ),
    ),
    onAddStory: () { /* abrir fluxo de criação */ },
  ),
);
```

### Abrir o viewer diretamente

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => StoryViewerPage(
      userGroups: stories,           // List<StorieModel>
      initialUserIndex: 0,
      onStoryView: (id) => repo.registerView(id),             // opcional
      onLike: (id, {required liked}) => repo.like(id, liked), // opcional
      onComment: (id, comment) => repo.postComment(id, comment), // opcional
    ),
  ),
);
```

### Customizando ícones e placeholder

Todos os parâmetros de customização são opcionais — os valores padrão reproduzem o comportamento original.

```dart
StoryViewerPage(
  userGroups: stories,
  initialUserIndex: 0,
  // ícone do botão de enviar comentário (padrão: Icons.send_rounded)
  sendIcon: Icons.arrow_upward_rounded,
  // ícones de curtida (padrões: Icons.favorite / Icons.favorite_border)
  likedIcon: Icons.thumb_up,
  unlikedIcon: Icons.thumb_up_outlined,
  // ícone de fechar (padrão: Icons.close)
  closeIcon: Icons.arrow_back,
  // placeholder do campo de comentário (padrão: 'Adicionar comentário...')
  commentHintText: 'Envie uma mensagem...',
)
```

| Parâmetro | Tipo | Padrão |
|---|---|---|
| `sendIcon` | `IconData` | `Icons.send_rounded` |
| `likedIcon` | `IconData` | `Icons.favorite` |
| `unlikedIcon` | `IconData` | `Icons.favorite_border` |
| `closeIcon` | `IconData` | `Icons.close` |
| `commentHintText` | `String` | `'Adicionar comentário...'` |

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
      isLiked: false,
      isViewed: false
      duration: 15
    ),
  ],
);
```

## Dependências

- [`video_player`](https://pub.dev/packages/video_player)
- [`cached_network_image`](https://pub.dev/packages/cached_network_image)
