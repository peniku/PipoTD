# Manual do jogador

## Objetivo
Impedir que as hordas cheguem ao seu **castelo**. Elas saem de um **portal mágico** e seguem a estrada de pedra. Sobreviva às 55 ondas.

## Controles
| Ação | Comando |
|---|---|
| Selecionar um lugar ou uma torre | clique esquerdo |
| Cancelar seleção | clique direito ou Esc |
| Iniciar a próxima onda | Espaço ou botão "Iniciar onda" |
| Mover a câmera | W A S D ou setas |
| Girar a câmera | Q / E |
| Zoom | roda do mouse |
| Recarregar números (`data/*.json`) | F5 |

## Como jogar
1. Clique em qualquer lugar livre em volta da estrada (o cursor fica dourado; os lugares disponíveis aparecem em dourado) e construa **Arqueiros** (alvo único, barato) ou **Catapulta** (dano em área).
2. Inicie a onda. Cada inimigo morto dá ouro.
3. No fim de cada onda você recebe **juros** sobre o ouro guardado.
4. Você começa com 1 **Favor Real** e ganha mais um a cada 5 ondas. Use na barra de baixo para comprar ou subir uma **Ordem**.
5. Clique numa torre para **evoluir**: base → Ordem nível 1 → 2 → 3, ou combinar duas Ordens numa torre **Dual**.
6. Vender devolve 75% de tudo que você gastou na torre.

## As Ordens e as fraquezas
Cada Ordem causa o dobro de dano na seguinte e metade na anterior:

```
Divino → Necromancia → Gelo → Fogo → Druídico → Terra → Divino
```

Cada Ordem de onda é uma **facção**, e os olhos dos inimigos brilham na cor da Ordem. A barra superior avisa qual facção vem na próxima onda.

| Facção | Ordem | Torre que causa dano dobrado |
|---|---|---|
| Horda Goblinoide | nenhuma | — |
| Cruzados Caídos | Divino | Terra |
| Legião Morta-Viva | Necromancia | Divino |
| Gigantes do Gelo | Gelo | Necromancia |
| Hordas Infernais | Fogo | Gelo |
| Bestas Selvagens | Druídico | Fogo |
| Constructos de Pedra | Terra | Druídico |

| Ordem | Especialidade |
|---|---|
| Divino | dano alto em um alvo |
| Necromancia | dano enorme, ataque lento |
| Gelo | deixa os inimigos lentos |
| Fogo | dano em área |
| Druídico | veneno ao longo do tempo |
| Terra | atordoa e ignora armadura |

## Tipos de onda
Normal · Rápida · Horda (muitos fracos) · Blindada (armadura) · Regeneração · Chefe (a cada 10 ondas; tira 10 vidas se passar). Chefes: Lich, Jarl dos Gigantes do Gelo, Senhor Demônio, Urso-Coruja Alfa, Golem Ancião, Paladino Caído, Senhor da Guerra Hobgoblin.
