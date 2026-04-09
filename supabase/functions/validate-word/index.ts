// Supabase Edge Function: validate-word
// Valida a palavra submetida e persiste a pontuação se válida.
// Deploy: supabase functions deploy validate-word

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const {
      round_id,
      player_id,
      word,
      locale,
      theme,
      raw_points,
    }: {
      round_id: string;
      player_id: string;
      word: string;
      locale: string;
      theme: string;
      raw_points: number;
    } = await req.json();

    // ── Validações básicas ──────────────────────────────────────────────────
    if (!word || word.length < 2) {
      return new Response(
        JSON.stringify({ valid: false, reason: "too_short" }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // ── Verifica se a rodada existe e está ativa ────────────────────────────
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const { data: round, error: roundError } = await supabase
      .from("rounds")
      .select("id, letters, theme, bet_time")
      .eq("id", round_id)
      .single();

    if (roundError || !round) {
      return new Response(
        JSON.stringify({ valid: false, reason: "round_not_found" }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // ── Verifica se as letras da palavra estão no tabuleiro ─────────────────
    const boardLetters: string[] = round.letters;
    const wordLetters = word.toUpperCase().split("");
    const available = [...boardLetters];

    for (const char of wordLetters) {
      const idx = available.indexOf(char);
      if (idx === -1) {
        return new Response(
          JSON.stringify({ valid: false, reason: "letters_not_in_board" }),
          { headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }
      available.splice(idx, 1);
    }

    // ── Verifica no dicionário (tabela auxiliar ou arquivo externo) ─────────
    // Aqui você pode integrar com um dicionário externo ou tabela Postgres.
    // Por ora, aceita qualquer palavra com ≥ 3 letras que use letras do tabuleiro.
    const isValidWord = word.length >= 3;

    if (!isValidWord) {
      return new Response(
        JSON.stringify({ valid: false, reason: "not_in_dictionary" }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // ── Verifica se o jogador já usou essa palavra nesta rodada ─────────────
    const { data: existing } = await supabase
      .from("scores")
      .select("id")
      .eq("round_id", round_id)
      .eq("player_id", player_id)
      .eq("word", word.toUpperCase())
      .maybeSingle();

    if (existing) {
      return new Response(
        JSON.stringify({ valid: false, reason: "already_used" }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // ── Persiste a pontuação ────────────────────────────────────────────────
    const scoreId = crypto.randomUUID();
    const { data: score, error: scoreError } = await supabase
      .from("scores")
      .insert({
        id: scoreId,
        round_id,
        player_id,
        word: word.toUpperCase(),
        points: raw_points,
        validated_at: new Date().toISOString(),
      })
      .select()
      .single();

    if (scoreError) throw scoreError;

    return new Response(
      JSON.stringify({ valid: true, score }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 200,
      }
    );
  } catch (err) {
    return new Response(
      JSON.stringify({ valid: false, reason: "server_error", detail: String(err) }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 500,
      }
    );
  }
});
