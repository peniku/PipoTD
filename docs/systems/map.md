# Sistema: Mapa, rota e grade de construção

**Código:** `scripts/world/main.gd` (funções `_build_*`, `_pick_cell`, `_select_cell`), `scripts/world/build_grid.gd` (classe `BuildGrid`)
**Dados:** `data/maps/map_01.json`

## Como o mapa é montado
O mapa inteiro vem do JSON; não existe cena de mapa desenhada à mão. A lógica (rota, grade) fica em `main.gd`/`build_grid.gd`; o visual (estrada, portal, castelo, floresta) em `scripts/visual/world_builder.gd`, configurado pelo bloco `scenery`.

| Campo | Uso |
|---|---|
| `ground_size` | `[largura, profundidade]` do chão em metros |
| `path` | lista de pontos `[x, z]`; vira uma `Curve3D` num `Path3D` chamado `Route` |
| `path_width` | largura visual da estrada |
| `build_grid.cell_size` | tamanho de cada célula em metros (cada torre ocupa 1 célula) |
| `build_grid.road_clearance` | folga extra entre a estrada e as células (0 = pode encostar) |
| `build_grid.end_clearance` | raio em volta da entrada e do castelo sem construção |
| `build_grid.blocked_cells` | lista de `[coluna, linha]` bloqueadas à mão (decoração, rio…) |

- Coordenadas: plano X/Z, Y é a altura. O centro do mapa é `(0, 0)`.
- O primeiro ponto da rota é a **entrada** (portal mágico) e o último é o **castelo**. Ambos são orientados automaticamente pela direção da rota.
- A estrada é calçamento de pedra por segmento (só visual; não tem colisão).

## Grade de construção (estilo Element TD)
Em vez de lugares fixos, o chão inteiro é uma grade e o jogador constrói em **qualquer célula livre** em volta da rota.

- A grade cobre `ground_size` dividido em células de `cell_size`. No mapa 1: 22 × 16 células de 2 m, das quais **248 são construíveis**.
- Uma célula é bloqueada se o quadrado dela encostar na estrada (distância do centro à rota < `path_width/2 + cell_size/2 + road_clearance`), se estiver perto da entrada/castelo, ou se estiver em `blocked_cells`.
- Células construíveis aparecem com quadrados dourados suaves (`MultiMesh`) **só quando o jogador seleciona uma célula livre** (modo construção) — `show_overlay()`. No resto do tempo o chão fica limpo.
- **Cursor:** o quadrado sob o mouse fica dourado (pode construir ou tem torre) ou vermelho (bloqueado).
- **Seleção:** quadrado amarelo na célula clicada.

## Clique
`main._pick_cell` lança o raio da câmera contra o plano do chão (y = 0), sem física, e converte o ponto em célula (`BuildGrid.world_to_cell`).
- Célula com torre → painel da torre.
- Célula livre → painel de construção.
- Célula bloqueada → limpa a seleção.

## API do `BuildGrid`
`is_buildable(c)`, `is_free(c)`, `tower_at(c)`, `place_tower(c, torre)`, `remove_tower(c)`, `cell_to_world(c)`, `world_to_cell(pos)`, `buildable_cells()`.

## Criar um mapa novo
1. Copie `data/maps/map_01.json` para `map_02.json` e edite `path`, `ground_size` e `build_grid`.
2. Em `main.gd`, troque `map_id` (é um `@export`, dá para mudar pelo inspetor do Godot selecionando o nó Main).
3. Rode o jogo: a grade se ajusta sozinha à nova rota.
