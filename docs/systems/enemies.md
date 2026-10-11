# Sistema: Inimigos

**Código:** `scripts/entities/enemy.gd` (classe `Enemy`)
**Dados:** `data/economy.json` → `waves.types`

## O que é
Um `PathFollow3D` filho da rota (`Route`). Andar = aumentar `progress` (metros percorridos). Quando `progress_ratio` chega a 1, o inimigo alcançou o castelo.

## Atributos (definidos por `setup()` a partir da onda)
| Atributo | Significado |
|---|---|
| `max_hp` / `hp` | vida |
| `speed` | metros por segundo |
| `order` | Ordem do inimigo (`"fogo"`, …) ou `null`. Define a cor e os multiplicadores de dano |
| `armor` | fração do dano bloqueada (0,35 = bloqueia 35%) |
| `regen` | fração da vida máxima recuperada por segundo |
| `gold_reward` | ouro ao morrer |
| `wave_type` | tipo da onda (`normal`, `chefe`…) |

## Efeitos de status
| Efeito | Origem | Comportamento |
|---|---|---|
| Lentidão | habilidade `slow` | velocidade × (1 − amount) por `duration` s; não acumula, vale o mais forte |
| Atordoar | habilidade `stun` | chance de parar totalmente por `duration` s |
| Veneno | habilidade `poison` | dano por segundo = dano do golpe × `dps_ratio`, por `duration` s; ignora armadura |

## Sinais
- `died(enemy, gold_reward)` — morreu; o `WaveManager` dá o ouro.
- `reached_end(enemy)` — chegou ao castelo; o `WaveManager` tira vidas (`lives_lost`).

## Visual
Modelo da facção (`scripts/visual/enemy_model.gd`, escolhido por `elements.json → factions.<ordem>.model`), animação de caminhada, barra de vida com fundo escuro que só aparece após o primeiro dano. Ao morrer: explosão de partículas e "+ouro" flutuando. Detalhes em [../art-direction.md](../art-direction.md#inimigos-facções).
