## 0.1.12

* O story é exibido num quadro 9:16 (1080×1920) encostado no topo, com cantos arredondados — o mesmo enquadramento do editor, sem cortar as laterais em telas mais altas que 9:16.
* A barra de resposta (campo + curtir) e a barra do dono ficam abaixo da imagem, sobre fundo preto, em vez de sobrepostas à foto.
* Ao digitar, a barra sobe com o teclado por cima da imagem, que escurece para o campo ficar legível. Tocar na imagem escurecida fecha o teclado em vez de trocar de story.

## 0.1.10

* Adiciona o parâmetro `confirmDelete` (padrão `true`) em `StoryViewerPage`. Quando `false`, o viewer chama `onDeleteStory` diretamente, sem o diálogo interno, permitindo que o app apresente a própria UI de exclusão (ex.: menu com "excluir" ou "remover do destaque").

## 0.1.7

* Adiciona callback `onAvatarTap` em `StoryViewerPage`: chamado com o `StorieModel` do grupo atual ao tocar no avatar ou nome do usuário no header.

## 0.1.6

* Versão anterior.

## 0.0.1

* Release inicial.
