# Sistema: HUD (interface)

**Código:** `scripts/ui/hud.gd` (classe `HUD`, um `CanvasLayer` montado por código, com um `Control` raiz que carrega o tema medieval)

## Partes
| Parte | Posição | Conteúdo |
|---|---|---|
| Barra superior | topo | Ouro, Vidas, Onda, Favor Real · próxima onda (facção ou chefe, tipo, quantidade) · botão "Chamar a onda" · botão **Menu** |
| Painel lateral | direita | célula livre: torres para construir · torre: dados, DPS, **mira (5 botões)**, evoluções (com requisitos), demolir |
| Barra de Ordens | rodapé (centro) | um botão por Ordem na cor dela, nível como ◆◆◇; habilitado quando há Favor Real |
| Anúncio de onda | topo-centro | "Onda N" + facção/chefe, aparece e some sozinho (`announce_wave`) |
| Mensagem | centro | vitória/derrota + "Jogar de novo" + "Menu principal" |

## Regras
- O HUD **só emite sinais**; quem executa é `main.gd` (ver [../architecture.md](../architecture.md)).
- Redesenha sozinho em `GameState.changed`, mantendo o painel aberto na torre/célula selecionada.
- Botões ficam desabilitados quando falta ouro, requisito de Ordem ou Favor.

## Tema visual
`_make_theme()`: painéis quase pretos com borda dourada, botões marrom-escuros que acendem ao passar o mouse, fonte serifada do sistema (`HUD.serif_font()`: Cinzel → Trajan → Georgia → …), texto cor de pergaminho. A mesma fonte é usada no "+ouro" 3D.

## Sinais
`start_wave_pressed`, `build_pressed(id)`, `upgrade_pressed(id)`, `sell_pressed`, `targeting_pressed(mode)`, `order_pressed(order)`, `restart_pressed`, `menu_pressed`.

## Idioma
Todo texto vem de `Loc.t()`. Ao trocar de idioma (`Loc.language_changed`) o HUD chama `_retranslate()`. O tema (`make_theme()`, `panel_style()`) é público para o menu reaproveitar.
