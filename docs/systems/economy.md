# Sistema: Economia, vidas e Ordens

**Código:** `scripts/autoload/game_state.gd` (singleton `GameState`)
**Dados:** `data/economy.json`

## Ouro
- Começa com `start_gold`.
- Ganha por abate (fórmula em [waves.md](waves.md)) e por juros.
- **Juros:** ao fim de cada onda, `ouro × interest_per_wave`, arredondado para baixo e limitado a `interest_cap`. Guardar ouro rende; gastar fortalece agora.
- Gasta ao construir/evoluir; vender devolve `sell_refund` do total gasto na torre.

## Vidas
- Começa com `start_lives`.
- Inimigo que chega ao castelo tira `lives_lost[tipo]` (ou `lives_lost.default`). Chefe tira 10.
- Vidas = 0 → sinal `game_over(onda)`.

## Favor Real e Ordens
- Começa com `start_favor` Favor Real.
- Ganha +1 a cada `favor_every_n_waves` ondas concluídas (5, 10, 15…).
- Cada nível de Ordem custa `order_level_cost_favor`. Máximo `order_max_level` (3).
- `meets_requirements(requires)` confere se o jogador tem as Ordens nos níveis pedidos por uma torre.

## Sinais
- `changed` — qualquer valor mudou (o HUD redesenha).
- `game_over(wave_reached)`.
