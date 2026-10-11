# PipoTd — Plataforma e arquitetura

## Engine: Godot 4

Escolhido por: 3D com espaço para escalar a parte gráfica, gratuito/open source, exporta para PC (Steam), web e mobile, e tem multiplayer de alto nível embutido (`MultiplayerAPI` + ENet/WebSocket).

Versão: **Godot 4.5** (testado com 4.5.1). Linguagem: **GDScript** (troca para C# só se aparecer gargalo de performance).

## Princípios de arquitetura

1. **Dados separados do código.** Dano, velocidade de ataque, range, custos, ondas e multiplicadores vivem em `data/*.json`. O código só lê. Isso é o que torna o painel de balanceamento possível.
2. **Simulação separada da renderização.** A lógica (ondas, vida, alvo, dano) não depende de modelos 3D. Facilita o multiplayer (servidor roda a mesma lógica) e testes.
3. **Multiplayer "corrida":** cada jogador tem sua própria rota/instância de simulação. O servidor só precisa sincronizar início das ondas, vidas e quem foi eliminado. Pouco tráfego, sem necessidade de lockstep.

## Estrutura de pastas

Ver [architecture.md](architecture.md).

## Multiplayer (fases)

1. Single player funcionando com os dados.
2. Corrida PvP: lobby, mesmas ondas para todos, ranking por quem dura mais.
3. Futuro: enviar inimigos para o adversário, co-op, etc.
