# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Instalar dependências
flutter pub get

# Gerar localizations (após alterar arquivos .arb)
flutter gen-l10n

# Executar app (com variáveis de ambiente)
flutter run \
  --dart-define=SUPABASE_URL=https://SEU_PROJETO.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=SUA_ANON_KEY \
  --dart-define=REVENUECAT_ANDROID_KEY=appl_xxx \
  --dart-define=REVENUECAT_IOS_KEY=appl_xxx

# Rodar todos os testes
flutter test

# Rodar um teste específico
flutter test test/game_state_test.dart

# Build release (Android)
flutter build apk --release --dart-define=...

# Deploy Edge Function Supabase
supabase functions deploy validate-word
```

## Arquitetura

O projeto segue arquitetura em camadas: **UI → Riverpod Notifiers → Domain → Data**.

```
lib/
  main.dart                   — Inicialização (Supabase, RevenueCat, AdMob, Hive)
  core/
    router/app_router.dart    — GoRouter + HomeScreen (menu principal)
    theme/                    — AppColors + AppTheme (tema dark-only)
    utils/
      ad_manager.dart         — Singleton AdMob intersticial
      revenue_cat_manager.dart — Singleton RevenueCat + stream isPro
  data/
    models/
      game_state.dart         — GameState, GamePhase, BetOption, WordFeedback
      player.dart / room.dart / round.dart / score.dart
    repositories/
      game_repository.dart    — Toda I/O Supabase (players, rooms, rounds, scores, realtime)
      dictionary_repository.dart — Dicionário offline via Hive
  features/
    game/
      notifiers/game_notifier.dart   — Máquina de estados principal (matchmaking → bet → play → end)
      notifiers/timer_notifier.dart  — Contador regressivo isolado
      widgets/tile_grid.dart         — Grade 5×3 de letras
      widgets/timer_widget.dart      — CustomPainter circular
      widgets/bet_selector.dart      — Cards de aposta (5s/10s/20s)
      screens/game_screen.dart       — Orquestra as 4 views (waiting/betting/playing/roundEnd)
      screens/result_screen.dart     — Placar final + dispara anúncio AdMob
    auth/
      notifiers/auth_notifier.dart   — Supabase Auth state
      screens/login_screen.dart / profile_screen.dart
    ranking/
      notifiers/ranking_notifier.dart
      screens/leaderboard_screen.dart
  l10n/
    app_pt.arb / app_en.arb / app_es.arb   — Strings de UI
    letter_theme_factory.dart              — Frequência de letras por idioma/tema
```

## Fluxo do jogo

1. **Matchmaking** (`GamePhase.waiting`): insere na fila Supabase; timeout 10s → IA local
2. **Betting** (`GamePhase.betting`): cada jogador escolhe 5s/10s/20s; quando ambos escolhem → inicia rodada
3. **Playing** (`GamePhase.playing`): toca tiles para formar palavras; timer circular; submissão valida localmente (Hive) depois no servidor (Edge Function `validate-word`)
4. **Round end** (`GamePhase.roundEnd`): exibe placar; avança à próxima rodada ou `gameEnd`
5. **Game end** → navega para `ResultScreen` que pode disparar anúncio intersticial

## Realtime (multiplayer)

Canal Supabase: `room:{uuid}`. Eventos broadcast:
- `tile_selected` — índices selecionados pelo oponente
- `word_submitted` — palavra enviada
- `round_ended` — placar final da rodada
- `score_updated` — pontuação acumulada
- `bet_placed` — aposta do oponente

A validação de pontuação **sempre** passa pela Edge Function `supabase/functions/validate-word/`. O cliente nunca escreve diretamente na tabela `scores`.

## Monetização

- `RevenueCatManager.instance.isPro` — bool síncrono; `isProStream` — stream reativo
- Anúncio: `AdManager.instance.showInterstitialIfNeeded(roundCount, isPro)` — chamado apenas na `ResultScreen` após 1s de delay
- Regra: `!isPro && roundCount % 5 == 0 && !isFirstSession`

## Internacionalização

- Strings: `lib/l10n/*.arb` — rodar `flutter gen-l10n` após qualquer alteração
- Dicionários: `assets/dictionaries/{pt,en,es}.txt` — um token por linha, maiúsculas
- Frequência de letras: `LetterThemeFactory` em `lib/l10n/letter_theme_factory.dart`

## Banco de dados

Schema completo em `supabase/schema.sql`. Tabelas principais:
- `players` — perfil e total_score
- `rooms` — sala de jogo (player_a, player_b, locale, theme, status)
- `rounds` — rodada (letters[], bet_time)
- `scores` — palavras válidas (inseridas somente pela Edge Function)
- `matchmaking_queue` — fila por locale; limpeza automática de entradas > 30s

## Variáveis de ambiente

Passadas via `--dart-define` em runtime (nunca commitadas):
- `SUPABASE_URL`, `SUPABASE_ANON_KEY`
- `REVENUECAT_ANDROID_KEY`, `REVENUECAT_IOS_KEY`
- AdMob App IDs ficam em `AndroidManifest.xml` e `Info.plist`
