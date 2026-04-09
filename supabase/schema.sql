-- ============================================================
-- Duelo de Palavras — Esquema Supabase
-- Execute no SQL Editor do dashboard Supabase
-- ============================================================

-- Extensão UUID
create extension if not exists "pgcrypto";

-- ─── players ─────────────────────────────────────────────────────────────────
create table if not exists public.players (
  id           uuid primary key default gen_random_uuid(),
  username     text not null,
  locale       text not null default 'pt' check (locale in ('pt', 'en', 'es')),
  total_score  integer not null default 0,
  created_at   timestamptz not null default now()
);

-- Índice para ranking
create index if not exists idx_players_total_score on public.players (total_score desc);
create index if not exists idx_players_locale on public.players (locale);

-- ─── rooms ───────────────────────────────────────────────────────────────────
create table if not exists public.rooms (
  id          uuid primary key default gen_random_uuid(),
  player_a    uuid not null references public.players (id) on delete cascade,
  player_b    uuid references public.players (id) on delete set null,
  locale      text not null default 'pt',
  theme       text not null default 'food',
  status      text not null default 'waiting' check (status in ('waiting', 'playing', 'finished')),
  created_at  timestamptz not null default now()
);

create index if not exists idx_rooms_status on public.rooms (status);
create index if not exists idx_rooms_player_a on public.rooms (player_a);

-- ─── rounds ──────────────────────────────────────────────────────────────────
create table if not exists public.rounds (
  id          uuid primary key default gen_random_uuid(),
  room_id     uuid not null references public.rooms (id) on delete cascade,
  letters     text[] not null,          -- array com 15 letras
  theme       text not null,
  bet_time    integer not null check (bet_time in (10, 15, 20)),
  started_at  timestamptz not null default now()
);

create index if not exists idx_rounds_room_id on public.rounds (room_id);

-- ─── scores ──────────────────────────────────────────────────────────────────
create table if not exists public.scores (
  id           uuid primary key default gen_random_uuid(),
  round_id     uuid not null references public.rounds (id) on delete cascade,
  player_id    uuid not null references public.players (id) on delete cascade,
  word         text not null,
  points       integer not null default 0,
  validated_at timestamptz default now()
);

create index if not exists idx_scores_round_id on public.scores (round_id);
create index if not exists idx_scores_player_id on public.scores (player_id);

-- ─── matchmaking_queue ────────────────────────────────────────────────────────
create table if not exists public.matchmaking_queue (
  id          uuid primary key default gen_random_uuid(),
  player_id   uuid not null unique references public.players (id) on delete cascade,
  locale      text not null default 'pt',
  created_at  timestamptz not null default now()
);

create index if not exists idx_queue_locale on public.matchmaking_queue (locale, created_at);

-- ─── Row Level Security ───────────────────────────────────────────────────────

-- players: qualquer usuário autenticado lê; só o dono escreve
alter table public.players enable row level security;

create policy "Leitura pública de players"
  on public.players for select using (true);

create policy "Jogador edita só o próprio perfil"
  on public.players for update
  using (auth.uid() = id);

create policy "Inserção via service_role ou dono"
  on public.players for insert
  with check (auth.uid() = id);

-- rooms: participantes lêem; apenas player_a cria
alter table public.rooms enable row level security;

create policy "Participantes lêem a sala"
  on public.rooms for select
  using (auth.uid() = player_a or auth.uid() = player_b);

create policy "player_a cria a sala"
  on public.rooms for insert
  with check (auth.uid() = player_a);

create policy "Participantes atualizam a sala"
  on public.rooms for update
  using (auth.uid() = player_a or auth.uid() = player_b);

-- rounds: participantes da sala lêem e inserem
alter table public.rounds enable row level security;

create policy "Participantes lêem rounds"
  on public.rounds for select
  using (
    exists (
      select 1 from public.rooms r
      where r.id = rounds.room_id
        and (r.player_a = auth.uid() or r.player_b = auth.uid())
    )
  );

create policy "Participantes criam rounds"
  on public.rounds for insert
  with check (
    exists (
      select 1 from public.rooms r
      where r.id = rounds.room_id
        and (r.player_a = auth.uid() or r.player_b = auth.uid())
    )
  );

-- scores: participantes da rodada lêem; inserção via Edge Function (service_role)
alter table public.scores enable row level security;

create policy "Participantes lêem scores"
  on public.scores for select
  using (
    exists (
      select 1 from public.rounds rd
      join public.rooms r on r.id = rd.room_id
      where rd.id = scores.round_id
        and (r.player_a = auth.uid() or r.player_b = auth.uid())
    )
  );

-- matchmaking_queue: autenticados inserem/deletam/lêem (próprio registro)
alter table public.matchmaking_queue enable row level security;

create policy "Jogador entra na fila"
  on public.matchmaking_queue for insert
  with check (auth.uid() = player_id);

create policy "Jogador sai da fila"
  on public.matchmaking_queue for delete
  using (auth.uid() = player_id);

create policy "Qualquer autenticado lê a fila"
  on public.matchmaking_queue for select
  using (auth.role() = 'authenticated');

-- ─── Função: atualiza total_score após inserção de score ─────────────────────
create or replace function public.update_player_score()
returns trigger language plpgsql security definer as $$
begin
  update public.players
  set total_score = total_score + new.points
  where id = new.player_id;
  return new;
end;
$$;

create trigger trg_update_player_score
  after insert on public.scores
  for each row execute function public.update_player_score();

-- ─── Realtime: habilita broadcast nas salas ───────────────────────────────────
-- Execute no dashboard: Database → Replication → ativar para tabelas relevantes
-- ou use apenas Supabase Broadcast (sem persistência), que não precisa configuração extra.

-- ─── Limpeza automática da fila de matchmaking (> 30s) ───────────────────────
create or replace function public.cleanup_matchmaking_queue()
returns void language sql security definer as $$
  delete from public.matchmaking_queue
  where created_at < now() - interval '30 seconds';
$$;

-- Para executar automaticamente, configure um pg_cron job:
-- select cron.schedule('cleanup-queue', '* * * * *', 'select public.cleanup_matchmaking_queue()');
