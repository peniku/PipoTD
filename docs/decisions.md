# Registro de decisões

Cada decisão importante, com data e motivo. Nova decisão = nova entrada no topo.

## D-009 · 2026-10-11 · Dual usa a primeira Ordem como tipo de dano
Torres Duais têm duas Ordens, mas o dano usa só a primeira da lista (`element[0]`) para o multiplicador. Simples e previsível. A segunda Ordem aparece nas habilidades únicas (Fase 3).

## D-008 · 2026-10-11 · Evoluir custa o preço cheio da torre-alvo
Evoluir Arqueiros → Fogo Nv1 cobra o `cost` inteiro de Fogo Nv1. O total gasto fica guardado na torre; vender devolve `sell_refund` (75%) desse total.

## D-007 · 2026-10-11 · Pedra ignora armadura
Inimigos blindados reduzem dano em % (`armor`). Ordens em `armor_piercing_orders` (hoje só Pedra) ignoram isso, dando um papel claro à Pedra.

## D-006 · 2026-10-11 · HUD e mundo montados por código
Em vez de cenas .tscn complexas, `main.gd` e `hud.gd` criam os nós por código. Mais fácil de ler, revisar e alterar por texto (inclusive por IA). Quando entrarem modelos 3D reais, as torres/inimigos podem virar cenas.

## D-005 · 2026-10-11 · Todos os números em JSON
Nada de balanceamento fixo no código. Permite o painel de balanceamento e o F5 para recarregar ao vivo.

## D-004 · 2026-10-11 · Multiplayer começa como corrida "quem dura mais"
Cada jogador defende sua própria rota com as mesmas ondas. Pouca sincronização necessária. Interações (enviar inimigos, co-op) ficam para depois.

## D-003 · 2026-10-11 · Rota fixa no início
Mazing (labirinto com as torres) fica para o futuro.

## D-002 · 2026-10-11 · Godot 4 (GDScript)
3D com espaço para escalar o visual, gratuito, exporta para PC/web/mobile, multiplayer embutido. Escolhido no lugar de web (Phaser/TS) por causa do 3D.

## D-001 · 2026-10-11 · Medieval mapeando 1:1 o Element TD 2
6 Ordens (Sagrado, Necromancia, Gelo, Fogo, Druídico, Pedra) no lugar dos 6 elementos, preservando a roda de fraquezas que já é equilibrada.
