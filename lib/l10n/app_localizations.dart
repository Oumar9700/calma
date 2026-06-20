import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
    Locale('fr'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In fr, this message translates to:
  /// **'CALMA'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In fr, this message translates to:
  /// **'Comme À La Maison'**
  String get appTagline;

  /// No description provided for @continueAction.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get continueAction;

  /// No description provided for @skipAction.
  ///
  /// In fr, this message translates to:
  /// **'Passer'**
  String get skipAction;

  /// No description provided for @saveAction.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get saveAction;

  /// No description provided for @cancelAction.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancelAction;

  /// No description provided for @deleteAction.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get deleteAction;

  /// No description provided for @editAction.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get editAction;

  /// No description provided for @confirmAction.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get confirmAction;

  /// No description provided for @backAction.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get backAction;

  /// No description provided for @retryAction.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retryAction;

  /// No description provided for @closeAction.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get closeAction;

  /// No description provided for @yesAction.
  ///
  /// In fr, this message translates to:
  /// **'Oui'**
  String get yesAction;

  /// No description provided for @noAction.
  ///
  /// In fr, this message translates to:
  /// **'Non'**
  String get noAction;

  /// No description provided for @sendAction.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer'**
  String get sendAction;

  /// No description provided for @searchAction.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher'**
  String get searchAction;

  /// No description provided for @filterAction.
  ///
  /// In fr, this message translates to:
  /// **'Filtrer'**
  String get filterAction;

  /// No description provided for @seeAllAction.
  ///
  /// In fr, this message translates to:
  /// **'Voir tout'**
  String get seeAllAction;

  /// No description provided for @loadMoreAction.
  ///
  /// In fr, this message translates to:
  /// **'Charger plus'**
  String get loadMoreAction;

  /// No description provided for @onboardingTitle1.
  ///
  /// In fr, this message translates to:
  /// **'Des plats qui rappellent chez vous'**
  String get onboardingTitle1;

  /// No description provided for @onboardingSubtitle1.
  ///
  /// In fr, this message translates to:
  /// **'Trouvez des plats préparés avec amour par vos camarades étudiants.'**
  String get onboardingSubtitle1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In fr, this message translates to:
  /// **'Partagez votre cuisine'**
  String get onboardingTitle2;

  /// No description provided for @onboardingSubtitle2.
  ///
  /// In fr, this message translates to:
  /// **'Vendez les plats de votre pays et faites découvrir votre culture.'**
  String get onboardingSubtitle2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In fr, this message translates to:
  /// **'Commandez facilement'**
  String get onboardingTitle3;

  /// No description provided for @onboardingSubtitle3.
  ///
  /// In fr, this message translates to:
  /// **'Commandez ou pré-commandez en quelques touches.'**
  String get onboardingSubtitle3;

  /// No description provided for @getStarted.
  ///
  /// In fr, this message translates to:
  /// **'Commencer'**
  String get getStarted;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai déjà un compte'**
  String get alreadyHaveAccount;

  /// No description provided for @loginTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bon retour'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous à votre compte'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In fr, this message translates to:
  /// **'Adresse email'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In fr, this message translates to:
  /// **'votre@email.com'**
  String get emailHint;

  /// No description provided for @passwordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In fr, this message translates to:
  /// **'Votre mot de passe'**
  String get passwordHint;

  /// No description provided for @forgotPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ?'**
  String get forgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get loginButton;

  /// No description provided for @noAccountYet.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de compte ?'**
  String get noAccountYet;

  /// No description provided for @signUpLink.
  ///
  /// In fr, this message translates to:
  /// **'S\'inscrire'**
  String get signUpLink;

  /// No description provided for @orWith.
  ///
  /// In fr, this message translates to:
  /// **'Ou avec'**
  String get orWith;

  /// No description provided for @continueWithGoogle.
  ///
  /// In fr, this message translates to:
  /// **'Continuer avec Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithApple.
  ///
  /// In fr, this message translates to:
  /// **'Continuer avec Apple'**
  String get continueWithApple;

  /// No description provided for @registerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Rejoignez la communauté CALMA'**
  String get registerSubtitle;

  /// No description provided for @firstNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Prénom'**
  String get firstNameLabel;

  /// No description provided for @lastNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get lastNameLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone (optionnel)'**
  String get phoneLabel;

  /// No description provided for @registerButton.
  ///
  /// In fr, this message translates to:
  /// **'Créer mon compte'**
  String get registerButton;

  /// No description provided for @alreadyHaveAccountLogin.
  ///
  /// In fr, this message translates to:
  /// **'Déjà un compte ?'**
  String get alreadyHaveAccountLogin;

  /// No description provided for @loginLink.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get loginLink;

  /// No description provided for @termsAgreement.
  ///
  /// In fr, this message translates to:
  /// **'En vous inscrivant, vous acceptez nos '**
  String get termsAgreement;

  /// No description provided for @termsOfService.
  ///
  /// In fr, this message translates to:
  /// **'Conditions d\'utilisation'**
  String get termsOfService;

  /// No description provided for @andThe.
  ///
  /// In fr, this message translates to:
  /// **' et la '**
  String get andThe;

  /// No description provided for @privacyPolicy.
  ///
  /// In fr, this message translates to:
  /// **'Politique de confidentialité'**
  String get privacyPolicy;

  /// No description provided for @roleSelectionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Comment souhaitez-vous utiliser CALMA ?'**
  String get roleSelectionTitle;

  /// No description provided for @roleBuyer.
  ///
  /// In fr, this message translates to:
  /// **'Acheteur'**
  String get roleBuyer;

  /// No description provided for @roleBuyerDescription.
  ///
  /// In fr, this message translates to:
  /// **'Je cherche des plats faits maison'**
  String get roleBuyerDescription;

  /// No description provided for @roleVendor.
  ///
  /// In fr, this message translates to:
  /// **'Vendeur'**
  String get roleVendor;

  /// No description provided for @roleVendorDescription.
  ///
  /// In fr, this message translates to:
  /// **'Je veux cuisiner et vendre mes plats'**
  String get roleVendorDescription;

  /// No description provided for @roleBoth.
  ///
  /// In fr, this message translates to:
  /// **'Les deux'**
  String get roleBoth;

  /// No description provided for @roleBothDescription.
  ///
  /// In fr, this message translates to:
  /// **'Je veux acheter et vendre'**
  String get roleBothDescription;

  /// No description provided for @homeTabLabel.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get homeTabLabel;

  /// No description provided for @exploreTabLabel.
  ///
  /// In fr, this message translates to:
  /// **'Explorer'**
  String get exploreTabLabel;

  /// No description provided for @ordersTabLabel.
  ///
  /// In fr, this message translates to:
  /// **'Commandes'**
  String get ordersTabLabel;

  /// No description provided for @postsTabLabel.
  ///
  /// In fr, this message translates to:
  /// **'Publications'**
  String get postsTabLabel;

  /// No description provided for @profileTabLabel.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get profileTabLabel;

  /// No description provided for @homeGreetingMorning.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour {name}'**
  String homeGreetingMorning(String name);

  /// No description provided for @homeGreetingAfternoon.
  ///
  /// In fr, this message translates to:
  /// **'Bon après-midi {name}'**
  String homeGreetingAfternoon(String name);

  /// No description provided for @homeGreetingEvening.
  ///
  /// In fr, this message translates to:
  /// **'Bonsoir {name}'**
  String homeGreetingEvening(String name);

  /// No description provided for @homeSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un plat, un pays, un vendeur...'**
  String get homeSearchHint;

  /// No description provided for @homeFeaturedVendors.
  ///
  /// In fr, this message translates to:
  /// **'Vendeurs à la une'**
  String get homeFeaturedVendors;

  /// No description provided for @homeAvailableToday.
  ///
  /// In fr, this message translates to:
  /// **'Disponibles aujourd\'hui'**
  String get homeAvailableToday;

  /// No description provided for @homeNearby.
  ///
  /// In fr, this message translates to:
  /// **'Près de vous'**
  String get homeNearby;

  /// No description provided for @homePopularDishes.
  ///
  /// In fr, this message translates to:
  /// **'Plats populaires'**
  String get homePopularDishes;

  /// No description provided for @vendorOpenNow.
  ///
  /// In fr, this message translates to:
  /// **'Ouvert maintenant'**
  String get vendorOpenNow;

  /// No description provided for @vendorClosedToday.
  ///
  /// In fr, this message translates to:
  /// **'Fermé aujourd\'hui'**
  String get vendorClosedToday;

  /// No description provided for @vendorPreorderAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Précommande disponible'**
  String get vendorPreorderAvailable;

  /// No description provided for @vendorRating.
  ///
  /// In fr, this message translates to:
  /// **'{rating} ({count} avis)'**
  String vendorRating(String rating, int count);

  /// No description provided for @vendorDishCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} plats'**
  String vendorDishCount(int count);

  /// No description provided for @vendorOrigin.
  ///
  /// In fr, this message translates to:
  /// **'Cuisine {country}'**
  String vendorOrigin(String country);

  /// No description provided for @dishPrice.
  ///
  /// In fr, this message translates to:
  /// **'{price} €'**
  String dishPrice(String price);

  /// No description provided for @dishOrderButton.
  ///
  /// In fr, this message translates to:
  /// **'Commander'**
  String get dishOrderButton;

  /// No description provided for @dishPreorderButton.
  ///
  /// In fr, this message translates to:
  /// **'Pré-commander'**
  String get dishPreorderButton;

  /// No description provided for @dishUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Indisponible'**
  String get dishUnavailable;

  /// No description provided for @dishPreparationTime.
  ///
  /// In fr, this message translates to:
  /// **'Prêt dans {time}'**
  String dishPreparationTime(String time);

  /// No description provided for @orderStatusPending.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get orderStatusPending;

  /// No description provided for @orderStatusAccepted.
  ///
  /// In fr, this message translates to:
  /// **'Acceptée'**
  String get orderStatusAccepted;

  /// No description provided for @orderStatusPreparing.
  ///
  /// In fr, this message translates to:
  /// **'En préparation'**
  String get orderStatusPreparing;

  /// No description provided for @orderStatusReady.
  ///
  /// In fr, this message translates to:
  /// **'Prête'**
  String get orderStatusReady;

  /// No description provided for @orderStatusCompleted.
  ///
  /// In fr, this message translates to:
  /// **'Livrée'**
  String get orderStatusCompleted;

  /// No description provided for @orderStatusCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Annulée'**
  String get orderStatusCancelled;

  /// No description provided for @orderStatusRejected.
  ///
  /// In fr, this message translates to:
  /// **'Refusée'**
  String get orderStatusRejected;

  /// No description provided for @preorderAcompteInstructions.
  ///
  /// In fr, this message translates to:
  /// **'Envoyez l\'acompte sur le compte {method} du vendeur ({handle}), puis uploadez la capture ci-dessous.'**
  String preorderAcompteInstructions(String method, String handle);

  /// No description provided for @preorderUploadCapture.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter la capture du paiement'**
  String get preorderUploadCapture;

  /// No description provided for @preorderCaptureAdded.
  ///
  /// In fr, this message translates to:
  /// **'Capture ajoutée'**
  String get preorderCaptureAdded;

  /// No description provided for @preorderSubmit.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer ma précommande'**
  String get preorderSubmit;

  /// No description provided for @preorderDisclaimerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Information importante'**
  String get preorderDisclaimerTitle;

  /// No description provided for @preorderDisclaimer.
  ///
  /// In fr, this message translates to:
  /// **'CALMA ne gère pas les transactions financières. Le paiement se fait directement entre vous et le vendeur. En cas de litige, CALMA peut tenter de médiation mais ne garantit aucun remboursement.'**
  String get preorderDisclaimer;

  /// No description provided for @cancellationWarning.
  ///
  /// In fr, this message translates to:
  /// **'Attention : {count} annulation(s) tardive(s) enregistrée(s) sur votre profil.'**
  String cancellationWarning(int count);

  /// No description provided for @cancellationThresholdWarning.
  ///
  /// In fr, this message translates to:
  /// **'Votre compte sera signalé après 3 annulations tardives.'**
  String get cancellationThresholdWarning;

  /// No description provided for @settingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settingsTitle;

  /// No description provided for @settingsProfile.
  ///
  /// In fr, this message translates to:
  /// **'Mon profil'**
  String get settingsProfile;

  /// No description provided for @settingsTheme.
  ///
  /// In fr, this message translates to:
  /// **'Apparence'**
  String get settingsTheme;

  /// No description provided for @settingsLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get settingsLanguage;

  /// No description provided for @settingsNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsAbout.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get settingsAbout;

  /// No description provided for @settingsLogout.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get settingsLogout;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer mon compte'**
  String get settingsDeleteAccount;

  /// No description provided for @themeLight.
  ///
  /// In fr, this message translates to:
  /// **'Clair'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In fr, this message translates to:
  /// **'Sombre'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In fr, this message translates to:
  /// **'Système'**
  String get themeSystem;

  /// No description provided for @themeAccentColor.
  ///
  /// In fr, this message translates to:
  /// **'Couleur principale'**
  String get themeAccentColor;

  /// No description provided for @languageFrench.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @languageEnglish.
  ///
  /// In fr, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @errorGeneric.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue. Veuillez réessayer.'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In fr, this message translates to:
  /// **'Pas de connexion internet.'**
  String get errorNetwork;

  /// No description provided for @errorNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Contenu introuvable.'**
  String get errorNotFound;

  /// No description provided for @errorUnauthorized.
  ///
  /// In fr, this message translates to:
  /// **'Vous n\'êtes pas autorisé à effectuer cette action.'**
  String get errorUnauthorized;

  /// No description provided for @errorEmailAlreadyUsed.
  ///
  /// In fr, this message translates to:
  /// **'Cette adresse email est déjà utilisée.'**
  String get errorEmailAlreadyUsed;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In fr, this message translates to:
  /// **'Email ou mot de passe incorrect.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorWeakPassword.
  ///
  /// In fr, this message translates to:
  /// **'Le mot de passe doit contenir au moins 8 caractères.'**
  String get errorWeakPassword;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In fr, this message translates to:
  /// **'Adresse email invalide.'**
  String get errorInvalidEmail;

  /// No description provided for @successProfileUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Profil mis à jour.'**
  String get successProfileUpdated;

  /// No description provided for @successOrderPlaced.
  ///
  /// In fr, this message translates to:
  /// **'Commande envoyée.'**
  String get successOrderPlaced;

  /// No description provided for @successPreorderPlaced.
  ///
  /// In fr, this message translates to:
  /// **'Précommande envoyée.'**
  String get successPreorderPlaced;

  /// No description provided for @successOrderAccepted.
  ///
  /// In fr, this message translates to:
  /// **'Commande acceptée.'**
  String get successOrderAccepted;

  /// No description provided for @successOrderCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Commande annulée.'**
  String get successOrderCancelled;

  /// No description provided for @emptyStateVendors.
  ///
  /// In fr, this message translates to:
  /// **'Aucun vendeur disponible pour le moment.'**
  String get emptyStateVendors;

  /// No description provided for @emptyStateDishes.
  ///
  /// In fr, this message translates to:
  /// **'Aucun plat disponible.'**
  String get emptyStateDishes;

  /// No description provided for @emptyStateOrders.
  ///
  /// In fr, this message translates to:
  /// **'Vous n\'avez pas encore de commandes.'**
  String get emptyStateOrders;

  /// No description provided for @emptyStatePosts.
  ///
  /// In fr, this message translates to:
  /// **'Aucune publication pour le moment.'**
  String get emptyStatePosts;

  /// No description provided for @emptyStateChats.
  ///
  /// In fr, this message translates to:
  /// **'Aucune conversation.'**
  String get emptyStateChats;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer la suppression'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmMessage.
  ///
  /// In fr, this message translates to:
  /// **'Cette action est irréversible. Voulez-vous continuer ?'**
  String get deleteConfirmMessage;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous vraiment vous déconnecter ?'**
  String get logoutConfirmMessage;

  /// No description provided for @referralBadgeAmbassador.
  ///
  /// In fr, this message translates to:
  /// **'Ambassadeur'**
  String get referralBadgeAmbassador;

  /// No description provided for @referralShareMessage.
  ///
  /// In fr, this message translates to:
  /// **'Rejoins CALMA et trouve des plats de chez toi ! {link}'**
  String referralShareMessage(String link);
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
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
