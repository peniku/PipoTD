# Changelog

Tudo que foi feito no projeto, do mais recente para o mais antigo.

## 2026-10-11 — Português/Inglês, menu principal e mira das torres
- **Idiomas PT/EN**: novo singleton `Loc` (`scripts/autoload/loc.gd`) e textos em `data/i18n/pt.json` e `en.json` (136 chaves). Todo texto de tela passou a usar `Loc.t()`. Nomes de torres, Ordens e facções saíram de `towers.json`/`elements.json` e foram para os arquivos de idioma. O idioma fica salvo em `user://settings.cfg`; na primeira vez segue o idioma do sistema.
- **Menu principal** (`scenes/menu.tscn`, agora a cena inicial): Jogar, Idioma (alterna e salva), Sair; fundo com o cenário do jogo, torres decorativas e câmera girando. Botão **Menu** no HUD e na tela de fim de jogo.
- **Mira das torres**: 5 modos por torre (da frente, de trás, mais HP, menos HP, mais próximo), botões no painel da torre e tecla **T**; mantida ao evoluir. `targeting` em `towers.json` = modo inicial.
- **Testes**: chaves iguais nos dois idiomas, nomes completos, troca de idioma no HUD, menu abre, os 5 modos de mira escolhem o inimigo certo.
- `docs/.gdignore`: o Godot ignora a pasta de documentação (as imagens não entram no jogo exportado).
- **Capturas**: `--lang=` e `--menu` em `tests/screenshot.tscn`; imagens `menu_pt.png`, `menu_en.png`, `targeting_en.png`.
- Docs: novos `systems/localization.md` e `systems/menu.md`; atualizados towers (tabela PT/EN), systems/towers (mira), hud, data-reference, architecture, manual, testing, CLAUDE.md (regra de textos), decisões D-014/D-015.

## 2026-10-11 — Tema D&D e visual medieval mágico
Pedido: "temática D&D, graficamente bonito, aparência medieval mágica, sem parecer jogo infantil".
- **Tema D&D (SRD 5.1)**: Ordens na tela viram Divino/Necromancia/Gelo/Fogo/Druídico/Terra (ids internos mantidos); torres renomeadas (Capela do Clérigo, Torre do Lich, Torre do Evocador, Treant Ancião…); 7 **facções inimigas** com chefes em `elements.json → factions`.
- **Cenário** (`scripts/visual/world_builder.gd`): céu crepuscular, sol baixo com sombras, SSAO, glow, névoa, terreno texturizado, estrada de calçamento, **portal** com redemoinho em shader, **castelo** com muralhas/torres/estandartes/tochas, floresta de pinheiros, rochas, grama, montanhas, partículas no ar. Configurável por `scenery` no mapa.
- **Torres** (`scripts/visual/tower_model.gd`): torre de vigia, catapulta animada, torres de pedra com cristal mágico flutuante por Ordem, níveis com mais detalhes, Duais com dois cristais orbitando; pisca ao atirar.
- **Inimigos** (`scripts/visual/enemy_model.gd`): goblin, cavaleiro caído, esqueleto, gigante do gelo, demônio, worg, golem; animação de caminhada; armadura nas ondas blindadas; chefes com coroa e aura.
- **Projéteis e efeitos** (`projectile.gd`, `scripts/visual/vfx.gd`): flecha, pedra em arco, orbe mágico com rastro; explosões, onda de choque, "+ouro" flutuante.
- **Interface**: tema medieval (bordas douradas, fonte serifada), anúncio de onda, Ordens com ◆◇.
- **Câmera**: mais cinematográfica, gira com Q/E.
- **Grade**: só aparece no modo construção.
- `tests/screenshot.tscn`: gera capturas de tela (inclui galeria de inimigos). Imagens em `docs/images/`.
- Godot 4.5.1 instalado em `E:\Projetos\Godot` no PC.
- CLAUDE.md: regra de sempre fazer commit + push no GitHub.
- Docs: novo art-direction.md; atualizados design, towers, data-reference, systems/*, manual, testing, setup, decisões D-011/D-012, CREDITS.md.

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
