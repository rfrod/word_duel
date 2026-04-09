// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Duelo de Palabras';

  @override
  String get ok => 'Aceptar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get close => 'Cerrar';

  @override
  String get back => 'Volver';

  @override
  String get loading => 'Cargando…';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Reintentar';

  @override
  String get playAgain => 'Jugar de nuevo';

  @override
  String get backToMenu => 'Menú principal';

  @override
  String get loginTitle => 'Iniciar sesión';

  @override
  String get loginButton => 'Entrar';

  @override
  String get logoutButton => 'Salir';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get anonymousLogin => 'Jugar como invitado';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get usernameLabel => 'Nombre de usuario';

  @override
  String get saveProfile => 'Guardar';

  @override
  String get waitingForOpponent => 'Esperando oponente…';

  @override
  String get opponentFound => '¡Oponente encontrado!';

  @override
  String get aiOpponent => 'Jugando contra IA';

  @override
  String searchingFor(String locale) {
    return 'Buscando jugador en $locale…';
  }

  @override
  String get bettingTitle => 'Elige tu apuesta';

  @override
  String get betFast => '10s — ×2 pts';

  @override
  String get betNormal => '15s — ×1 pt';

  @override
  String get betSlow => '20s — ×0,5 pt';

  @override
  String get confirmBet => 'Confirmar apuesta';

  @override
  String roundLabel(int current, int total) {
    return 'Ronda $current de $total';
  }

  @override
  String themeLabel(String theme) {
    return 'Tema: $theme';
  }

  @override
  String get submitWord => 'Enviar';

  @override
  String get clearWord => 'Borrar';

  @override
  String validWord(int points) {
    return '¡Palabra válida! +$points pts';
  }

  @override
  String get invalidWord => 'Palabra inválida';

  @override
  String get timeUp => '¡Tiempo agotado!';

  @override
  String get roundEnded => 'Ronda terminada';

  @override
  String get yourScore => 'Tú';

  @override
  String get opponentScore => 'Oponente';

  @override
  String roundWinner(String name) {
    return '¡$name ganó la ronda!';
  }

  @override
  String get draw => '¡Empate!';

  @override
  String get nextRound => 'Siguiente ronda';

  @override
  String get gameOver => '¡Fin del juego!';

  @override
  String get youWin => '¡Ganaste!';

  @override
  String get youLose => '¡Perdiste!';

  @override
  String get finalScore => 'Puntuación final';

  @override
  String totalPoints(int points) {
    return '$points puntos';
  }

  @override
  String get leaderboardTitle => 'Clasificación';

  @override
  String get rankLabel => '#';

  @override
  String get playerLabel => 'Jugador';

  @override
  String get scoreLabel => 'Puntos';

  @override
  String get noRankingData => 'Aún no hay datos de clasificación.';

  @override
  String get themeFood => 'Gastronomía';

  @override
  String get themeAnimals => 'Animales';

  @override
  String get themeSports => 'Deportes';

  @override
  String get themeTech => 'Tecnología';

  @override
  String get upgradeToPro => 'Hazte Pro';

  @override
  String get monthlyPlan => 'Plan Mensual';

  @override
  String get yearlyPlan => 'Plan Anual';

  @override
  String get priceMonthly => '\$3,99/mes';

  @override
  String get priceYearly => '\$24,99/año';

  @override
  String get noAds => 'Sin anuncios';

  @override
  String get allLanguages => 'Todos los idiomas';

  @override
  String get globalRanking => 'Clasificación global';

  @override
  String get extraThemes => 'Temas extra';

  @override
  String get buyLanguagePack => 'Pack de idioma — \$1,99';

  @override
  String get buyThemePack => 'Pack de tema — \$1,49';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String get alreadyPro => '¡Ya eres Pro!';

  @override
  String adCountdown(int seconds) {
    return 'Cerrar en ${seconds}s';
  }
}
