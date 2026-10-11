# PipoTd — Design do jogo

Tower defense 3D de **fantasia medieval mágica inspirada em D&D** (conteúdo SRD 5.1), com tom sombrio e adulto, inspirado no **Element TD 2** (ETD2). Visual: [art-direction.md](art-direction.md).

## Decisões fechadas (2026-10-11)

| Tema | Decisão |
|---|---|
| Visual | **3D** |
| Engine | **Godot 4** (ver [platform.md](platform.md)) |
| Rota | **Fixa** no início (mazing pode vir depois) |
| Multiplayer | **Corrida "quem dura mais"**: cada jogador na sua rota, mesmas ondas. Outras interações (enviar inimigos, co-op) ficam para o futuro |
| Balanceamento | Todos os números em arquivos de dados (`data/*.json`), editáveis por um painel |
| Tema | Fantasia D&D (SRD 5.1), sombria, não infantil — decisão D-011 |

## Referência: como o ETD2 funciona

- Até 8 jogadores, 55 ondas + chefe infinito, 6 elementos.
- **Torres base sem elemento:** Arrow (alvo único) e Cannon (área).
- **Elementos** são comprados/evoluídos com um recurso ganho periodicamente. Os elementos escolhidos definem quais torres você pode construir.
- **Camadas de torre:** Single (1 elemento, níveis 1→4) → Dual (2) → Triple (3, divididas em suporte e dano) → Quad (4) → Periodic (todos os 6).
- **Roda de fraquezas:** cada elemento é forte contra um e fraco contra outro. As ondas também têm elemento, então o jogador monta um elemento principal + um secundário para cobrir a fraqueza.
- **Tipos de onda** (massa, rápida, chefe, regeneração…) existem para que dano em área não resolva tudo.
- **Economia:** ouro para construir + juros sobre o ouro guardado (gastar agora × guardar).

## Versão medieval

### As 6 Ordens (equivalentes aos elementos)

| ETD2 | PipoTd | Papel |
|---|---|---|
| Luz | **Divino** (id `sagrado`) | dano alto, alvo único |
| Trevas | **Necromancia** | dano enorme, lento, maldições |
| Água | **Gelo** | desacelerar |
| Fogo | **Fogo** | dano em área |
| Natureza | **Druídico** | veneno, raízes, dano ao longo do tempo |
| Terra | **Terra** (id `pedra`) | atordoar, empurrar, dano contra armadura |

### Roda de fraquezas

Ciclo (cada um é forte contra o seguinte):

```
Divino → Necromancia → Gelo → Fogo → Druídico → Terra → Divino
```

- Atacar o elemento do qual você é forte: multiplicador **forte** (inicial x2.0).
- Atacar o elemento que é forte contra você: multiplicador **fraco** (inicial x0.5).
- Demais: x1.0. Dano elemental contra inimigo sem Ordem: x0.8.
- Todos os valores ficam em `data/elements.json` e serão ajustados no balanceamento.

### Inimigos

Cada Ordem de onda é uma facção D&D: Horda Goblinoide (sem Ordem), Cruzados Caídos (Divino), Legião Morta-Viva (Necromancia), Gigantes do Gelo (Gelo), Hordas Infernais (Fogo), Bestas Selvagens (Druídico), Constructos de Pedra (Terra). Cada uma tem um chefe (Lich, Jarl do Gelo, Senhor Demônio…). Tabela completa em [art-direction.md](art-direction.md#inimigos-facções). Tipos de onda previstos: normal, rápida, massa, blindada, regeneração, chefe.

### Recursos

- **Ouro** — construir e evoluir torres. Juros por onda sobre o ouro guardado.
- **Favor Real** — ganho a cada X ondas. Compra uma Ordem nova ou sobe o nível de uma Ordem.

### Evolução das torres

Ver [towers.md](towers.md).
