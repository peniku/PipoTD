# Changelog

Tudo que foi feito no projeto, do mais recente para o mais antigo.

## 2026-10-11 — Grade de construção estilo Element TD
- Os 29 lugares fixos (`BuildSlot`) foram substituídos por uma **grade** (`scripts/world/build_grid.gd`): o jogador constrói em qualquer célula livre em volta da rota. Mapa 1: 248 células construíveis.
- Células que encostam na estrada, perto da entrada/castelo ou listadas em `blocked_cells` ficam bloqueadas.
- Cursor verde/vermelho seguindo o mouse; quadrado amarelo na seleção; quadrados claros mostram onde dá para construir.
- O clique agora usa o plano do chão (sem física).
- `map_01.json`: campo `slots` removido; novo bloco `build_grid`.
- Teste automático atualizado (confere a grade e que não dá para construir em célula ocupada).
- Proposta de tema D&D registrada em docs/ideas/tema-dnd.md.
- Docs atualizados: systems/map.md reescrito, architecture, data-reference, testing, hud, towers, manual, decisions (D-010).

## 2026-10-11 — Base jogável (Fase 1)
- Mapa `map_01` "Vale do Rei" montado a partir de `data/maps/map_01.json`: chão, rota fixa em zigue-zague, estrada, entrada (verde), saída/castelo (vermelho) e 29 slots.
- Inimigos (`enemy.gd`) seguem a rota com vida, Ordem (cor), armadura, regeneração, barra de vida e efeitos de lentidão/veneno/atordoar.
- Ondas (`wave_manager.gd`) geradas pela fórmula de `economy.json`: 6 tipos (normal, rápida, massa, blindada, regeneração, chefe), Ordem a partir da onda 5.
- Torres (`tower.gd`) com mira no inimigo mais adiantado, projéteis, dano em área, evolução e venda. Visual provisório com formas simples coloridas pela Ordem.
- Economia (`game_state.gd`): ouro, vidas, juros com teto, Favor Real a cada 5 ondas, compra de Ordens.
- HUD por código: status, botão de onda, painel de construir/evoluir/vender, barra de Ordens, mensagens de fim de jogo.
- F5 recarrega os JSON sem fechar o jogo.
- Teste automático `tests/smoke_test.tscn`.
- Dados novos: `kill_gold`, `lives_lost`, `sell_refund`, tipos de onda, cores das Ordens, `armor_piercing_orders`.
- Projeto atualizado para Godot 4.5.
- Documentação completa: CLAUDE.md, índice, to-do mestre, arquitetura, sistemas, referência de dados, testes, setup, manual do jogador.

## 2026-10-11 — Decisões e estrutura (Fase 0)
- Estudo do Element TD 2 e adaptação medieval (6 Ordens, roda de fraquezas, Ouro + Favor Real).
- Decisões: 3D, Godot 4, rota fixa, multiplayer "quem dura mais".
- 35 torres da v1 em `data/towers.json`.
- Repositório criado: github.com/peniku/PipoTD.
