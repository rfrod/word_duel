import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt')
  ];

  /// Nome do aplicativo
  ///
  /// In pt, this message translates to:
  /// **'Duelo de Palavras'**
  String get appTitle;

  /// No description provided for @ok.
  ///
  /// In pt, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get close;

  /// No description provided for @back.
  ///
  /// In pt, this message translates to:
  /// **'Voltar'**
  String get back;

  /// No description provided for @loading.
  ///
  /// In pt, this message translates to:
  /// **'Carregando…'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In pt, this message translates to:
  /// **'Erro'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get retry;

  /// No description provided for @playAgain.
  ///
  /// In pt, this message translates to:
  /// **'Jogar novamente'**
  String get playAgain;

  /// No description provided for @backToMenu.
  ///
  /// In pt, this message translates to:
  /// **'Menu principal'**
  String get backToMenu;

  /// No description provided for @loginTitle.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get loginTitle;

  /// No description provided for @loginButton.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get loginButton;

  /// No description provided for @logoutButton.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get logoutButton;

  /// No description provided for @emailLabel.
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get passwordLabel;

  /// No description provided for @anonymousLogin.
  ///
  /// In pt, this message translates to:
  /// **'Jogar como visitante'**
  String get anonymousLogin;

  /// No description provided for @profileTitle.
  ///
  /// In pt, this message translates to:
  /// **'Perfil'**
  String get profileTitle;

  /// No description provided for @usernameLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nome de usuário'**
  String get usernameLabel;

  /// No description provided for @saveProfile.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get saveProfile;

  /// No description provided for @waitingForOpponent.
  ///
  /// In pt, this message translates to:
  /// **'Aguardando oponente…'**
  String get waitingForOpponent;

  /// No description provided for @opponentFound.
  ///
  /// In pt, this message translates to:
  /// **'Oponente encontrado!'**
  String get opponentFound;

  /// No description provided for @aiOpponent.
  ///
  /// In pt, this message translates to:
  /// **'Jogando contra IA'**
  String get aiOpponent;

  /// No description provided for @searchingFor.
  ///
  /// In pt, this message translates to:
  /// **'Buscando jogador em {locale}…'**
  String searchingFor(String locale);

  /// No description provided for @bettingTitle.
  ///
  /// In pt, this message translates to:
  /// **'Escolha sua aposta'**
  String get bettingTitle;

  /// No description provided for @betFast.
  ///
  /// In pt, this message translates to:
  /// **'10s — ×2 pts'**
  String get betFast;

  /// No description provided for @betNormal.
  ///
  /// In pt, this message translates to:
  /// **'15s — ×1 pt'**
  String get betNormal;

  /// No description provided for @betSlow.
  ///
  /// In pt, this message translates to:
  /// **'20s — ×0,5 pt'**
  String get betSlow;

  /// No description provided for @confirmBet.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar aposta'**
  String get confirmBet;

  /// No description provided for @roundLabel.
  ///
  /// In pt, this message translates to:
  /// **'Rodada {current} de {total}'**
  String roundLabel(int current, int total);

  /// No description provided for @themeLabel.
  ///
  /// In pt, this message translates to:
  /// **'Tema: {theme}'**
  String themeLabel(String theme);

  /// No description provided for @submitWord.
  ///
  /// In pt, this message translates to:
  /// **'Enviar'**
  String get submitWord;

  /// No description provided for @clearWord.
  ///
  /// In pt, this message translates to:
  /// **'Limpar'**
  String get clearWord;

  /// No description provided for @validWord.
  ///
  /// In pt, this message translates to:
  /// **'Palavra válida! +{points} pts'**
  String validWord(int points);

  /// No description provided for @invalidWord.
  ///
  /// In pt, this message translates to:
  /// **'Palavra inválida'**
  String get invalidWord;

  /// No description provided for @timeUp.
  ///
  /// In pt, this message translates to:
  /// **'Tempo esgotado!'**
  String get timeUp;

  /// No description provided for @roundEnded.
  ///
  /// In pt, this message translates to:
  /// **'Rodada encerrada'**
  String get roundEnded;

  /// No description provided for @yourScore.
  ///
  /// In pt, this message translates to:
  /// **'Você'**
  String get yourScore;

  /// No description provided for @opponentScore.
  ///
  /// In pt, this message translates to:
  /// **'Oponente'**
  String get opponentScore;

  /// No description provided for @roundWinner.
  ///
  /// In pt, this message translates to:
  /// **'{name} venceu a rodada!'**
  String roundWinner(String name);

  /// No description provided for @draw.
  ///
  /// In pt, this message translates to:
  /// **'Empate!'**
  String get draw;

  /// No description provided for @nextRound.
  ///
  /// In pt, this message translates to:
  /// **'Próxima rodada'**
  String get nextRound;

  /// No description provided for @gameOver.
  ///
  /// In pt, this message translates to:
  /// **'Fim de jogo!'**
  String get gameOver;

  /// No description provided for @youWin.
  ///
  /// In pt, this message translates to:
  /// **'Você venceu!'**
  String get youWin;

  /// No description provided for @youLose.
  ///
  /// In pt, this message translates to:
  /// **'Você perdeu!'**
  String get youLose;

  /// No description provided for @finalScore.
  ///
  /// In pt, this message translates to:
  /// **'Placar final'**
  String get finalScore;

  /// No description provided for @totalPoints.
  ///
  /// In pt, this message translates to:
  /// **'{points} pontos'**
  String totalPoints(int points);

  /// No description provided for @leaderboardTitle.
  ///
  /// In pt, this message translates to:
  /// **'Ranking'**
  String get leaderboardTitle;

  /// No description provided for @rankLabel.
  ///
  /// In pt, this message translates to:
  /// **'#'**
  String get rankLabel;

  /// No description provided for @playerLabel.
  ///
  /// In pt, this message translates to:
  /// **'Jogador'**
  String get playerLabel;

  /// No description provided for @scoreLabel.
  ///
  /// In pt, this message translates to:
  /// **'Pontos'**
  String get scoreLabel;

  /// No description provided for @noRankingData.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum dado de ranking ainda.'**
  String get noRankingData;

  /// No description provided for @themeFood.
  ///
  /// In pt, this message translates to:
  /// **'Culinária'**
  String get themeFood;

  /// No description provided for @themeAnimals.
  ///
  /// In pt, this message translates to:
  /// **'Animais'**
  String get themeAnimals;

  /// No description provided for @themeSports.
  ///
  /// In pt, this message translates to:
  /// **'Esportes'**
  String get themeSports;

  /// No description provided for @themeTech.
  ///
  /// In pt, this message translates to:
  /// **'Tecnologia'**
  String get themeTech;

  /// No description provided for @upgradeToPro.
  ///
  /// In pt, this message translates to:
  /// **'Upgrade para Pro'**
  String get upgradeToPro;

  /// No description provided for @monthlyPlan.
  ///
  /// In pt, this message translates to:
  /// **'Plano Mensal'**
  String get monthlyPlan;

  /// No description provided for @yearlyPlan.
  ///
  /// In pt, this message translates to:
  /// **'Plano Anual'**
  String get yearlyPlan;

  /// No description provided for @priceMonthly.
  ///
  /// In pt, this message translates to:
  /// **'R\$ 12,90/mês'**
  String get priceMonthly;

  /// No description provided for @priceYearly.
  ///
  /// In pt, this message translates to:
  /// **'R\$ 89,90/ano'**
  String get priceYearly;

  /// No description provided for @noAds.
  ///
  /// In pt, this message translates to:
  /// **'Sem anúncios'**
  String get noAds;

  /// No description provided for @allLanguages.
  ///
  /// In pt, this message translates to:
  /// **'Todos os idiomas'**
  String get allLanguages;

  /// No description provided for @globalRanking.
  ///
  /// In pt, this message translates to:
  /// **'Ranking global'**
  String get globalRanking;

  /// No description provided for @extraThemes.
  ///
  /// In pt, this message translates to:
  /// **'Temas extras'**
  String get extraThemes;

  /// No description provided for @buyLanguagePack.
  ///
  /// In pt, this message translates to:
  /// **'Pack de idioma — R\$ 6,90'**
  String get buyLanguagePack;

  /// No description provided for @buyThemePack.
  ///
  /// In pt, this message translates to:
  /// **'Pack de tema — R\$ 4,90'**
  String get buyThemePack;

  /// No description provided for @restorePurchases.
  ///
  /// In pt, this message translates to:
  /// **'Restaurar compras'**
  String get restorePurchases;

  /// No description provided for @alreadyPro.
  ///
  /// In pt, this message translates to:
  /// **'Você já é Pro!'**
  String get alreadyPro;

  /// No description provided for @adCountdown.
  ///
  /// In pt, this message translates to:
  /// **'Fechar em {seconds}s'**
  String adCountdown(int seconds);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
