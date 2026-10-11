# PipoTd — Status

## Feito
- 2026-10-11: decisões de design (3D, Godot 4, rota fixa, multiplayer corrida "quem dura mais").
- Mapeamento ETD2 → medieval: 6 Ordens, roda de fraquezas, Ouro + Favor Real.
- Árvore de evolução e as 35 torres da v1 em `data/towers.json` (valores provisórios).
- Projeto Godot inicial + autoload `GameData` que lê os JSON e calcula DPS / multiplicador de Ordem.

## Próximos passos
1. Cena de teste 3D: mapa com rota fixa (Path3D), spawn de inimigos seguindo a rota.
2. Construir torre base em slots, mirar e atirar usando `GameData`.
3. Ondas a partir de `economy.json`, ouro, juros, vidas.
4. Comprar Ordens com Favor Real e evoluir torres (Single → Dual).
5. Painel de balanceamento (plugin do editor + painel F1 no jogo).
6. Multiplayer corrida.

## Em aberto
- Nome definitivo do jogo (PipoTd é provisório).
- Estilo visual 3D (low poly estilizado? realista?).
- Mecânica exata de cada habilidade das Duais.
