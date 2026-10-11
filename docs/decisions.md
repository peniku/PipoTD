# Registro de decisões

Cada decisão importante, com data e motivo. Nova decisão = nova entrada no topo.

## D-013 · 2026-10-11 · Sempre publicar no GitHub
Todo trabalho termina com commit + push em peniku/PipoTD, docs incluídas. Pedido do dono, para que o projeto esteja sempre atualizado em qualquer máquina/sessão.

## D-012 · 2026-10-11 · Visual 100% procedural por enquanto
Modelos e texturas são gerados por código (formas primitivas + ruído), sem arquivos de arte. Motivo: iterar rápido e manter tudo em texto revisável. Modelos 3D de verdade (Blender/assets) entram na Fase 5 substituindo `tower_model.gd` / `enemy_model.gd` sem mexer na lógica. Lógica e visual ficam em scripts separados (`scripts/visual/`).

## D-011 · 2026-10-11 · Tema D&D (SRD 5.1), sombrio e adulto
Aprovado pelo dono. Usa só vocabulário do SRD/genérico (goblins, lich, gigantes do gelo, demônios, urso-coruja, golem, clérigo, paladino), nunca marcas da Wizards (nome D&D, Forgotten Realms, beholder, devorador de mentes). Crédito CC-BY-4.0 em CREDITS.md. Ids internos das Ordens não mudaram (`sagrado`, `pedra`) para não quebrar dados; só os nomes de tela (Divino, Terra).

## D-010 · 2026-10-11 · Grade de construção em vez de lugares fixos
Como no Element TD, o chão em volta da rota é uma grade de células de 2 m e o jogador constrói em qualquer célula livre. Dá muito mais liberdade de posicionamento (248 células no mapa 1, antes 29). A grade é calculada a partir da rota, então mapas novos não precisam listar lugares à mão.

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
