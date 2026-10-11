# Sistema: Ondas

**Código:** `scripts/world/wave_manager.gd` (classe `WaveManager`)
**Dados:** `data/economy.json` → `waves`, `kill_gold`, `lives_lost`

## Fórmula da onda `n` (`describe_wave(n)`)
1. **Tipo:** `pattern[(n − 1) % tamanho_do_pattern]`. O pattern atual repete a cada 10 ondas, terminando num chefe (ondas 10, 20, 30…).
2. **Ordem:** sem Ordem antes de `first_elemental_wave` (5). A partir dela, percorre `cycle` de `elements.json`: onda 5 = Sagrado, 6 = Necromancia, 7 = Gelo…
3. **Vida:** `base_hp × hp_growth_per_wave^(n−1) × hp_mult_do_tipo`, × `elemental_hp_multiplier` se tiver Ordem.
4. **Velocidade:** `base_speed × speed_mult_do_tipo`.
5. **Quantidade, armadura, regeneração, tamanho:** do tipo.
6. **Facção:** `faction` e `boss_name` vêm de `elements.json → factions` pela Ordem da onda (usados no HUD e no anúncio).
7. **Ouro por abate:** `(kill_gold.base + kill_gold.growth_per_wave × (n−1)) × gold_mult_do_tipo`, mínimo 1.

`describe_wave` é estática e pura: o futuro painel de balanceamento pode usá-la para desenhar a curva de dificuldade.

## Ciclo de uma onda
- `start_next_wave()` só funciona se não houver onda ativa e o jogo não acabou.
- Um inimigo nasce a cada `spawn_interval` segundos.
- A onda termina quando todos nasceram **e** todos morreram ou passaram → `GameState.on_wave_cleared()` (juros e Favor) e sinal `wave_cleared`.
- Depois da última onda (`count` = 55) → `all_waves_cleared` (vitória).

## Tipos de onda atuais
| Tipo | Ideia |
|---|---|
| normal | referência |
| rapida | menos vida, muito mais rápida |
| massa | muitos inimigos fracos (bom para área) |
| blindada | armadura 35% (Pedra ignora) |
| regeneracao | recupera 3% da vida por segundo |
| chefe | um só, vida ×12, tira 10 vidas se passar |
