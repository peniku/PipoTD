# Sistema: HUD (interface)

**Código:** `scripts/ui/hud.gd` (classe `HUD`, um `CanvasLayer` montado por código)

## Partes
| Parte | Posição | Conteúdo |
|---|---|---|
| Barra superior | topo | Ouro, Vidas, Onda, Favor Real · resumo da próxima onda · botão "Iniciar onda" |
| Painel lateral | direita | slot vazio: torres para construir · torre: dados, DPS, evoluções (com requisitos), vender |
| Barra de Ordens | rodapé | um botão por Ordem com nível atual; habilitado quando há Favor Real |
| Mensagem | centro | vitória/derrota + "Jogar de novo" |

## Regras
- O HUD **só emite sinais**; quem executa é `main.gd` (ver [../architecture.md](../architecture.md)).
- Redesenha sozinho em `GameState.changed`, mantendo o painel aberto na torre/slot selecionado.
- Botões ficam desabilitados quando falta ouro, requisito de Ordem ou Favor.

## Sinais
`start_wave_pressed`, `build_pressed(id)`, `upgrade_pressed(id)`, `sell_pressed`, `order_pressed(order)`, `restart_pressed`.
