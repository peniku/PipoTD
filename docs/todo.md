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
- [x] Slots de construção clicáveis
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

## Fase 3 — Conteúdo das torres
- [ ] Implementar habilidades únicas das 15 Duais (hoje todas são `"todo"`) — ver [towers.md](towers.md)
- [ ] Prioridades de mira configuráveis (primeiro, mais forte, mais perto)
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
- [ ] Decidir estilo visual (low poly estilizado × realista)
- [ ] Modelos das torres por camada e Ordem
- [ ] Mapa decorado (castelo, árvores, rochas)
- [ ] Efeitos de projétil, impacto e morte
- [ ] Sons e música

## Fase 6 — Multiplayer "quem dura mais"
- [ ] Separar totalmente simulação (lógica) do visual ([architecture.md](architecture.md))
- [ ] Lobby (criar/entrar em sala)
- [ ] Cada jogador com sua instância de mapa, mesmas ondas no mesmo ritmo
- [ ] Ranking ao vivo (onda, vidas)
- [ ] Servidor dedicado ou P2P (decidir)
- [ ] Futuro: enviar inimigos ao adversário, co-op

## Fase 7 — Polimento e lançamento
- [ ] Menu principal, opções, pausa
- [ ] Tutorial
- [ ] Mais mapas
- [ ] Nome definitivo do jogo
- [ ] Exportar para Windows; avaliar Steam

## Fora do jogo
- [ ] Ligar esta conversa ao PC (app desktop) para trabalhar em `E:\projetos\PipoTd`
- [ ] Clonar o repositório em `E:\projetos` ([setup.md](setup.md))
