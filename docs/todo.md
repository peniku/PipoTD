# To-do mestre do PipoTd

Toda tarefa planejada fica aqui. Marque `[x]` ao concluir e registre no [changelog.md](changelog.md).

Legenda: `[x]` feito · `[ ]` a fazer · `[~]` em andamento

---

## Fase 0 — Decisões e estrutura ✅
- [x] Estudar o Element TD 2 e definir a versão medieval ([design.md](design.md))
- [x] Escolher plataforma: Godot 4 ([decisions.md](decisions.md))
- [x] Definir: 3D, rota fixa, multiplayer "quem dura mais"
- [x] Árvore de evolução e as 35 torres da v1 ([towers.md](towers.md))
- [x] Criar repositório no GitHub (peniku/PipoTD)
- [x] Todos os números em `data/*.json`

## Fase 1 — Base jogável ✅
- [x] Mapa a partir de JSON: chão, rota fixa (Path3D), estrada, entrada/saída ([systems/map.md](systems/map.md))
- [x] Slots de construção clicáveis (substituído pela grade, ver abaixo)
- [x] Grade de construção estilo Element TD: qualquer célula livre em volta da rota, cursor verde/vermelho ([systems/map.md](systems/map.md))
- [x] Câmera: mover (WASD/setas) e zoom (roda do mouse)
- [x] Inimigos andando na rota, com vida, Ordem, armadura e regeneração ([systems/enemies.md](systems/enemies.md))
- [x] Barra de vida dos inimigos
- [x] Ondas geradas a partir de `economy.json` (6 tipos, curva de vida, Ordem por onda) ([systems/waves.md](systems/waves.md))
- [x] Torres base (Arqueiros, Catapulta): mira no inimigo mais adiantado, projétil, dano em área ([systems/towers.md](systems/towers.md))
- [x] Multiplicador de dano por Ordem (roda de fraquezas) ([systems/combat.md](systems/combat.md))
- [x] Habilidades simples: lentidão (Gelo), veneno (Druídico), atordoar (Pedra)
- [x] Ouro, vidas, juros por onda, recompensa por abate ([systems/economy.md](systems/economy.md))
- [x] Favor Real e compra/nível de Ordens
- [x] Evoluir torres (base → Single → Dual) respeitando requisitos
- [x] Vender torre (devolve 75%)
- [x] HUD: barra superior, painel de construção/evolução, barra de Ordens ([systems/hud.md](systems/hud.md))
- [x] Fim de jogo (derrota/vitória) e "jogar de novo"
- [x] F5 recarrega os JSON com o jogo aberto
- [x] Teste automático (smoke test) ([testing.md](testing.md))

## Fase 2 — Painel de balanceamento (próxima prioridade)
- [ ] Painel in-game (F1): escolher torre, sliders de dano / velocidade / alcance / área / custo
- [ ] Mostrar DPS e DPS por ouro calculados na hora
- [ ] Botão "salvar no towers.json"
- [ ] Ajustar também `economy.json` (vida das ondas, juros, ouro inicial)
- [ ] Gráfico da curva de vida das ondas × DPS médio
- [ ] Plugin no editor Godot com tabela de todas as torres
- [ ] Simulador: rodar N ondas sem tela com uma build e mostrar até onde chega

## Tema e universo ✅
- [x] Decidir tema: D&D (SRD 5.1), sombrio — [ideas/tema-dnd.md](ideas/tema-dnd.md), decisão D-011
- [x] Renomear Ordens (Divino, Terra…), torres e criar 7 facções inimigas com chefes ([art-direction.md](art-direction.md))
- [ ] Textos de lore curtos para cada facção e torre (tooltip / manual)

## Idiomas e menu ✅
- [x] Sistema de idiomas PT/EN (`Loc`, `data/i18n/`) ([systems/localization.md](systems/localization.md))
- [x] Todos os textos do jogo traduzidos
- [x] Menu principal com escolha de idioma salva ([systems/menu.md](systems/menu.md))
- [ ] Tela de opções (volume, qualidade gráfica, idioma)
- [ ] Traduzir o manual do jogador para inglês (docs/manual/player-en.md)

## Fase 3 — Conteúdo das torres
- [ ] Implementar habilidades únicas das 15 Duais (hoje todas são `"todo"`) — ver [towers.md](towers.md)
- [x] Mira configurável por torre: da frente, de trás, mais HP, menos HP, mais próximo (painel + tecla T) ([systems/towers.md](systems/towers.md#mira-escolhida-pelo-jogador))
- [ ] Torres de suporte (aura de dano, aura de velocidade)
- [ ] Projetar as 20 Triples (suporte × dano)
- [ ] Primeira passada de balanceamento das 35 torres

## Fase 4 — Ondas e inimigos
- [ ] Modelos/visual por facção (mortos-vivos, bestas, gigantes de gelo…)
- [ ] Chefes com habilidades
- [ ] Inimigos voadores? (decidir)
- [ ] Chefe infinito após a onda 55
- [ ] Mostrar a próxima onda com mais detalhe (Ordem, tipo, vida)

## Fase 5 — Visual 3D
- [x] Estilo visual: fantasia medieval sombria, crepúsculo, magia brilhante ([art-direction.md](art-direction.md))
- [x] Céu, luz, sombras, névoa, glow, SSAO
- [x] Terreno texturizado, estrada de pedra, floresta, rochas, grama, montanhas, partículas no ar
- [x] Portal de entrada (shader) e castelo de saída
- [x] Modelos procedurais das torres por camada e Ordem (cristais, animação de disparo)
- [x] Modelos procedurais dos inimigos por facção + chefes + armadura
- [x] Efeitos de projétil (flecha, pedra em arco, magia), impacto, área, morte, "+ouro"
- [x] Interface com tema medieval e anúncio de onda
- [x] Capturas de tela automáticas para revisar o visual ([testing.md](testing.md))
- [ ] Modelos 3D de verdade (Blender ou pacote de assets CC0) para torres e inimigos
- [ ] Texturas reais (PBR) para pedra, madeira e terreno
- [ ] Fonte Cinzel embutida no projeto (hoje usa a do sistema)
- [ ] Decoração dentro da área jogável usando `blocked_cells`
- [ ] Opção de qualidade gráfica (desligar SSAO/sombras/partículas em PCs fracos)
- [ ] Sons e música

## Fase 6 — Multiplayer "quem dura mais"
- [ ] Separar totalmente simulação (lógica) do visual ([architecture.md](architecture.md))
- [ ] Lobby (criar/entrar em sala)
- [ ] Cada jogador com sua instância de mapa, mesmas ondas no mesmo ritmo
- [ ] Ranking ao vivo (onda, vidas)
- [ ] Servidor dedicado ou P2P (decidir)
- [ ] Futuro: enviar inimigos ao adversário, co-op

## Fase 7 — Polimento e lançamento
- [x] Menu principal
- [ ] Opções, pausa
- [ ] Tutorial
- [ ] Mais mapas
- [ ] Nome definitivo do jogo
- [ ] Exportar para Windows; avaliar Steam

## Fora do jogo
- [x] Trabalhar direto no PC em `E:\Projetos\PipoTD`
- [x] Clonar o repositório em `E:\Projetos` ([setup.md](setup.md))
- [x] Instalar Godot 4.5.1 em `E:\Projetos\Godot`
