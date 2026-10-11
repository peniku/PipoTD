# Arquitetura do código

## Estrutura de pastas

```
PipoTd/
├── project.godot            # configuração do Godot (cena inicial, autoloads, janela)
├── CLAUDE.md                # regras para sessões de IA (documentar tudo)
├── README.md
├── data/                    # TODOS os números do jogo
│   ├── towers.json          # as 35 torres
│   ├── elements.json        # Ordens, roda de fraquezas, cores
│   ├── economy.json         # ouro, vidas, juros, ondas
│   └── maps/map_01.json     # rota e grade de construção do mapa
├── scenes/
│   └── main.tscn            # cena da partida (só um Node3D com main.gd)
├── scripts/
│   ├── autoload/
│   │   ├── game_data.gd     # GameData: lê os JSON
│   │   └── game_state.gd    # GameState: ouro, vidas, onda, Favor, Ordens
│   ├── world/
│   │   ├── main.gd          # monta o mundo, câmera, entrada do jogador
│   │   ├── wave_manager.gd  # gera e solta as ondas
│   │   └── build_grid.gd    # grade de construção em volta da rota
│   ├── entities/
│   │   ├── enemy.gd         # inimigo (PathFollow3D)
│   │   ├── tower.gd         # torre
│   │   └── projectile.gd    # projétil
│   ├── ui/
│   │   └── hud.gd           # interface da partida (tema medieval)
│   └── visual/              # SÓ visual, sem regra de jogo
│       ├── art.gd           # Art: materiais, texturas de ruído, malhas, partículas
│       ├── world_builder.gd # céu, luz, terreno, estrada, portal, castelo, floresta
│       ├── tower_model.gd   # TowerModel: modelo 3D de cada torre
│       ├── enemy_model.gd   # EnemyModel: modelo 3D de cada facção
│       └── vfx.gd           # VFX: explosões, clarões, "+ouro"
├── shaders/
│   └── portal.gdshader      # redemoinho do portal
├── tests/
│   ├── smoke_test.tscn/.gd  # teste automático
│   └── screenshot.tscn/.gd  # capturas de tela para revisar o visual
├── assets/models/           # modelos 3D (vazio por enquanto)
├── addons/                  # plugins (painel de balanceamento no futuro)
└── docs/                    # esta documentação
```

## Autoloads (singletons)

Carregados automaticamente pelo Godot antes de qualquer cena, nesta ordem:

| Nome | Script | Papel |
|---|---|---|
| `GameData` | `scripts/autoload/game_data.gd` | Lê `data/*.json`. Funções: `get_tower`, `dps`, `damage_multiplier`, `order_color`, `load_map`, `reload` |
| `GameState` | `scripts/autoload/game_state.gd` | Estado do jogador: ouro, vidas, onda, Favor Real, nível das Ordens. Sinais `changed` e `game_over` |

`GameState` depende de `GameData`, por isso vem depois.

## Árvore de nós durante a partida

```
Main (Node3D, main.gd)
├── DirectionalLight3D, WorldEnvironment
├── Ground (plano)
├── Route (Path3D)              ← rota fixa
│   └── Enemy ×N (PathFollow3D) ← inimigos andam aqui
├── segmentos da estrada, marcadores entrada/saída
├── BuildGrid (Node3D)          ← grade, cursor e marcador de seleção
│   ├── Tower ×N                ← torres construídas
│   └── Projectile ×N           ← projéteis das torres
├── Camera3D
├── WaveManager (Node)
└── HUD (CanvasLayer)
```

## Fluxo de uma partida

1. `main.gd._ready()` lê o mapa, chama `GameState.reset()` e monta mundo, câmera, `WaveManager` e `HUD`.
2. Jogador clica no chão → `_pick_cell` (raio da câmera × plano do chão) → célula livre: HUD mostra "construir"; célula com torre: painel da torre.
3. Construir → `GameState.spend(custo)` → `BuildGrid.place_tower(célula, torre)`.
4. Espaço/botão → `WaveManager.start_next_wave()` → calcula a onda com `describe_wave(n)` e solta inimigos no `Path3D`.
5. A cada frame cada `Tower` procura o inimigo mais adiantado no alcance e cria um `Projectile`.
6. Projétil chega → `Enemy.take_hit()` → aplica multiplicador de Ordem, armadura e habilidade.
7. Inimigo morre → `GameState.earn(ouro)`. Chega ao fim → `GameState.lose_life()`.
8. Onda acaba (todos mortos/passaram) → `GameState.on_wave_cleared()` → juros + Favor Real a cada 5 ondas.
9. Vidas = 0 → `game_over` → HUD mostra derrota. Onda 55 vencida → vitória.

## Comunicação entre partes

- **HUD não toma decisões.** Só emite sinais (`build_pressed`, `upgrade_pressed`, `sell_pressed`, `order_pressed`, `start_wave_pressed`, `restart_pressed`); o `main.gd` executa.
- **HUD se atualiza sozinho** escutando `GameState.changed`.
- **Torres leem os números a cada disparo** de `GameData`, então F5 (recarregar JSON) muda torres já construídas.

## Lógica × visual

Tudo que é só aparência mora em `scripts/visual/` e é chamado pelas entidades:
- `Tower` cria um `TowerModel` e chama `on_fire()` ao disparar.
- `Enemy` cria um `EnemyModel` e chama `animate()` a cada frame; ao morrer chama `VFX.impact` / `VFX.float_text`.
- `Projectile` desenha flecha/pedra/magia e chama `VFX.impact` no impacto.
- `main.gd` chama `WorldBuilder.build()` uma vez.

Trocar por modelos 3D reais = mexer só nesses arquivos.

Antes do multiplayer está previsto separar totalmente a simulação do visual (ver [todo.md](todo.md), Fase 6).

## Detalhes por sistema
Ver a pasta [systems/](README.md#sistemas-como-cada-parte-funciona-no-código).
