# Manual do jogador

## Objetivo
Impedir que os inimigos cheguem ao castelo (marcador vermelho). Eles entram pelo marcador verde e seguem a estrada. Sobreviva às 55 ondas.

## Controles
| Ação | Comando |
|---|---|
| Selecionar um lugar ou uma torre | clique esquerdo |
| Cancelar seleção | clique direito ou Esc |
| Iniciar a próxima onda | Espaço ou botão "Iniciar onda" |
| Mover a câmera | W A S D ou setas |
| Zoom | roda do mouse |
| Recarregar números (`data/*.json`) | F5 |

## Como jogar
1. Clique em qualquer quadrado claro em volta da estrada (o cursor fica verde) e construa **Arqueiros** (alvo único, barato) ou **Catapulta** (dano em área).
2. Inicie a onda. Cada inimigo morto dá ouro.
3. No fim de cada onda você recebe **juros** sobre o ouro guardado.
4. Você começa com 1 **Favor Real** e ganha mais um a cada 5 ondas. Use na barra de baixo para comprar ou subir uma **Ordem**.
5. Clique numa torre para **evoluir**: base → Ordem nível 1 → 2 → 3, ou combinar duas Ordens numa torre **Dual**.
6. Vender devolve 75% de tudo que você gastou na torre.

## As Ordens e as fraquezas
Cada Ordem causa o dobro de dano na seguinte e metade na anterior:

```
Sagrado → Necromancia → Gelo → Fogo → Druídico → Pedra → Sagrado
```

A cor do inimigo mostra a Ordem dele (cinza = nenhuma). A barra superior avisa a Ordem e o tipo da próxima onda.

| Ordem | Especialidade |
|---|---|
| Sagrado | dano alto em um alvo |
| Necromancia | dano enorme, ataque lento |
| Gelo | deixa os inimigos lentos |
| Fogo | dano em área |
| Druídico | veneno ao longo do tempo |
| Pedra | atordoa e ignora armadura |

## Tipos de onda
Normal · Rápida · Massa (muitos fracos) · Blindada (armadura) · Regeneração · Chefe (a cada 10 ondas; tira 10 vidas se passar).
