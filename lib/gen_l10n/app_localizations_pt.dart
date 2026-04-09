// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Duelo de Palavras';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancelar';

  @override
  String get close => 'Fechar';

  @override
  String get back => 'Voltar';

  @override
  String get loading => 'Carregando…';

  @override
  String get error => 'Erro';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get playAgain => 'Jogar novamente';

  @override
  String get backToMenu => 'Menu principal';

  @override
  String get loginTitle => 'Entrar';

  @override
  String get loginButton => 'Entrar';

  @override
  String get logoutButton => 'Sair';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get passwordLabel => 'Senha';

  @override
  String get anonymousLogin => 'Jogar como visitante';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get usernameLabel => 'Nome de usuário';

  @override
  String get saveProfile => 'Salvar';

  @override
  String get waitingForOpponent => 'Aguardando oponente…';

  @override
  String get opponentFound => 'Oponente encontrado!';

  @override
  String get aiOpponent => 'Jogando contra IA';

  @override
  String searchingFor(String locale) {
    return 'Buscando jogador em $locale…';
  }

  @override
  String get bettingTitle => 'Escolha sua aposta';

  @override
  String get betFast => '10s — ×2 pts';

  @override
  String get betNormal => '15s — ×1 pt';

  @override
  String get betSlow => '20s — ×0,5 pt';

  @override
  String get confirmBet => 'Confirmar aposta';

  @override
  String roundLabel(int current, int total) {
    return 'Rodada $current de $total';
  }

  @override
  String themeLabel(String theme) {
    return 'Tema: $theme';
  }

  @override
  String get submitWord => 'Enviar';

  @override
  String get clearWord => 'Limpar';

  @override
  String validWord(int points) {
    return 'Palavra válida! +$points pts';
  }

  @override
  String get invalidWord => 'Palavra inválida';

  @override
  String get timeUp => 'Tempo esgotado!';

  @override
  String get roundEnded => 'Rodada encerrada';

  @override
  String get yourScore => 'Você';

  @override
  String get opponentScore => 'Oponente';

  @override
  String roundWinner(String name) {
    return '$name venceu a rodada!';
  }

  @override
  String get draw => 'Empate!';

  @override
  String get nextRound => 'Próxima rodada';

  @override
  String get gameOver => 'Fim de jogo!';

  @override
  String get youWin => 'Você venceu!';

  @override
  String get youLose => 'Você perdeu!';

  @override
  String get finalScore => 'Placar final';

  @override
  String totalPoints(int points) {
    return '$points pontos';
  }

  @override
  String get leaderboardTitle => 'Ranking';

  @override
  String get rankLabel => '#';

  @override
  String get playerLabel => 'Jogador';

  @override
  String get scoreLabel => 'Pontos';

  @override
  String get noRankingData => 'Nenhum dado de ranking ainda.';

  @override
  String get themeFood => 'Culinária';

  @override
  String get themeAnimals => 'Animais';

  @override
  String get themeSports => 'Esportes';

  @override
  String get themeTech => 'Tecnologia';

  @override
  String get upgradeToPro => 'Upgrade para Pro';

  @override
  String get monthlyPlan => 'Plano Mensal';

  @override
  String get yearlyPlan => 'Plano Anual';

  @override
  String get priceMonthly => 'R\$ 12,90/mês';

  @override
  String get priceYearly => 'R\$ 89,90/ano';

  @override
  String get noAds => 'Sem anúncios';

  @override
  String get allLanguages => 'Todos os idiomas';

  @override
  String get globalRanking => 'Ranking global';

  @override
  String get extraThemes => 'Temas extras';

  @override
  String get buyLanguagePack => 'Pack de idioma — R\$ 6,90';

  @override
  String get buyThemePack => 'Pack de tema — R\$ 4,90';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String get alreadyPro => 'Você já é Pro!';

  @override
  String adCountdown(int seconds) {
    return 'Fechar em ${seconds}s';
  }
}
