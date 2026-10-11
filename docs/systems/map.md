# Sistema: Mapa, rota e slots

**Código:** `scripts/world/main.gd` (funções `_build_*`), `scripts/entities/build_slot.gd`
**Dados:** `data/maps/map_01.json`

## Como o mapa é montado
O mapa inteiro vem do JSON; não existe cena de mapa desenhada à mão.

| Campo | Uso |
|---|---|
| `ground_size` | `[largura, profundidade]` do chão em metros |
| `path` | lista de pontos `[x, z]`; vira uma `Curve3D` num `Path3D` chamado `Route` |
| `path_width` | largura visual da estrada |
| `slots` | lista de `[x, z]` onde o jogador pode construir |

- Coordenadas: plano X/Z, Y é a altura. O centro do mapa é `(0, 0)`.
- O primeiro ponto da rota é a **entrada** (marcador verde) e o último é o **castelo** (marcador vermelho).
- A estrada é desenhada com uma caixa achatada por segmento (só visual; não tem colisão).

## Slots de construção (`BuildSlot`)
- `StaticBody3D` com caixa de colisão de 1,8 m na **camada de física 2** (`PICK_LAYER`).
- O clique do mouse lança um raio da câmera que só enxerga a camada 2 (`main.gd._pick_slot`).
- Guarda `tower` (a torre construída, ou `null`).
- Selecionado = placa amarela + mostra o alcance da torre.

## Criar um mapa novo
1. Copie `data/maps/map_01.json` para `map_02.json` e edite `path` e `slots`.
2. Mantenha os slots a pelo menos ~2,5 m do centro da estrada.
3. Em `main.gd`, troque `map_id` (é um `@export`, dá para mudar pelo inspetor do Godot selecionando o nó Main).
