// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Word Duel';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get back => 'Back';

  @override
  String get loading => 'Loading…';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Retry';

  @override
  String get playAgain => 'Play again';

  @override
  String get backToMenu => 'Main menu';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginButton => 'Sign in';

  @override
  String get logoutButton => 'Sign out';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get anonymousLogin => 'Play as guest';

  @override
  String get profileTitle => 'Profile';

  @override
  String get usernameLabel => 'Username';

  @override
  String get saveProfile => 'Save';

  @override
  String get waitingForOpponent => 'Waiting for opponent…';

  @override
  String get opponentFound => 'Opponent found!';

  @override
  String get aiOpponent => 'Playing against AI';

  @override
  String searchingFor(String locale) {
    return 'Searching for a player in $locale…';
  }

  @override
  String get bettingTitle => 'Place your bet';

  @override
  String get betFast => '10s — ×2 pts';

  @override
  String get betNormal => '15s — ×1 pt';

  @override
  String get betSlow => '20s — ×0.5 pt';

  @override
  String get confirmBet => 'Confirm bet';

  @override
  String roundLabel(int current, int total) {
    return 'Round $current of $total';
  }

  @override
  String themeLabel(String theme) {
    return 'Theme: $theme';
  }

  @override
  String get submitWord => 'Submit';

  @override
  String get clearWord => 'Clear';

  @override
  String validWord(int points) {
    return 'Valid word! +$points pts';
  }

  @override
  String get invalidWord => 'Invalid word';

  @override
  String get timeUp => 'Time\'s up!';

  @override
  String get roundEnded => 'Round ended';

  @override
  String get yourScore => 'You';

  @override
  String get opponentScore => 'Opponent';

  @override
  String roundWinner(String name) {
    return '$name won the round!';
  }

  @override
  String get draw => 'Draw!';

  @override
  String get nextRound => 'Next round';

  @override
  String get gameOver => 'Game over!';

  @override
  String get youWin => 'You win!';

  @override
  String get youLose => 'You lose!';

  @override
  String get finalScore => 'Final score';

  @override
  String totalPoints(int points) {
    return '$points points';
  }

  @override
  String get leaderboardTitle => 'Leaderboard';

  @override
  String get rankLabel => '#';

  @override
  String get playerLabel => 'Player';

  @override
  String get scoreLabel => 'Points';

  @override
  String get noRankingData => 'No ranking data yet.';

  @override
  String get themeFood => 'Food';

  @override
  String get themeAnimals => 'Animals';

  @override
  String get themeSports => 'Sports';

  @override
  String get themeTech => 'Technology';

  @override
  String get upgradeToPro => 'Upgrade to Pro';

  @override
  String get monthlyPlan => 'Monthly Plan';

  @override
  String get yearlyPlan => 'Yearly Plan';

  @override
  String get priceMonthly => '\$3.99/month';

  @override
  String get priceYearly => '\$24.99/year';

  @override
  String get noAds => 'No ads';

  @override
  String get allLanguages => 'All languages';

  @override
  String get globalRanking => 'Global ranking';

  @override
  String get extraThemes => 'Extra themes';

  @override
  String get buyLanguagePack => 'Language pack — \$1.99';

  @override
  String get buyThemePack => 'Theme pack — \$1.49';

  @override
  String get restorePurchases => 'Restore purchases';

  @override
  String get alreadyPro => 'You\'re already Pro!';

  @override
  String adCountdown(int seconds) {
    return 'Close in ${seconds}s';
  }
}
