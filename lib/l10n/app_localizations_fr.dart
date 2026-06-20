// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'CALMA';

  @override
  String get appTagline => 'Comme À La Maison';

  @override
  String get continueAction => 'Continuer';

  @override
  String get skipAction => 'Passer';

  @override
  String get saveAction => 'Enregistrer';

  @override
  String get cancelAction => 'Annuler';

  @override
  String get deleteAction => 'Supprimer';

  @override
  String get editAction => 'Modifier';

  @override
  String get confirmAction => 'Confirmer';

  @override
  String get backAction => 'Retour';

  @override
  String get retryAction => 'Réessayer';

  @override
  String get closeAction => 'Fermer';

  @override
  String get yesAction => 'Oui';

  @override
  String get noAction => 'Non';

  @override
  String get sendAction => 'Envoyer';

  @override
  String get searchAction => 'Rechercher';

  @override
  String get filterAction => 'Filtrer';

  @override
  String get seeAllAction => 'Voir tout';

  @override
  String get loadMoreAction => 'Charger plus';

  @override
  String get onboardingTitle1 => 'Des plats qui rappellent chez vous';

  @override
  String get onboardingSubtitle1 =>
      'Trouvez des plats préparés avec amour par vos camarades étudiants.';

  @override
  String get onboardingTitle2 => 'Partagez votre cuisine';

  @override
  String get onboardingSubtitle2 =>
      'Vendez les plats de votre pays et faites découvrir votre culture.';

  @override
  String get onboardingTitle3 => 'Commandez facilement';

  @override
  String get onboardingSubtitle3 =>
      'Commandez ou pré-commandez en quelques touches.';

  @override
  String get getStarted => 'Commencer';

  @override
  String get alreadyHaveAccount => 'J\'ai déjà un compte';

  @override
  String get loginTitle => 'Bon retour';

  @override
  String get loginSubtitle => 'Connectez-vous à votre compte';

  @override
  String get emailLabel => 'Adresse email';

  @override
  String get emailHint => 'votre@email.com';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get passwordHint => 'Votre mot de passe';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get loginButton => 'Se connecter';

  @override
  String get noAccountYet => 'Pas encore de compte ?';

  @override
  String get signUpLink => 'S\'inscrire';

  @override
  String get orWith => 'Ou avec';

  @override
  String get continueWithGoogle => 'Continuer avec Google';

  @override
  String get continueWithApple => 'Continuer avec Apple';

  @override
  String get registerTitle => 'Créer un compte';

  @override
  String get registerSubtitle => 'Rejoignez la communauté CALMA';

  @override
  String get firstNameLabel => 'Prénom';

  @override
  String get lastNameLabel => 'Nom';

  @override
  String get phoneLabel => 'Téléphone (optionnel)';

  @override
  String get registerButton => 'Créer mon compte';

  @override
  String get alreadyHaveAccountLogin => 'Déjà un compte ?';

  @override
  String get loginLink => 'Se connecter';

  @override
  String get termsAgreement => 'En vous inscrivant, vous acceptez nos ';

  @override
  String get termsOfService => 'Conditions d\'utilisation';

  @override
  String get andThe => ' et la ';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get roleSelectionTitle => 'Comment souhaitez-vous utiliser CALMA ?';

  @override
  String get roleBuyer => 'Acheteur';

  @override
  String get roleBuyerDescription => 'Je cherche des plats faits maison';

  @override
  String get roleVendor => 'Vendeur';

  @override
  String get roleVendorDescription => 'Je veux cuisiner et vendre mes plats';

  @override
  String get roleBoth => 'Les deux';

  @override
  String get roleBothDescription => 'Je veux acheter et vendre';

  @override
  String get homeTabLabel => 'Accueil';

  @override
  String get exploreTabLabel => 'Explorer';

  @override
  String get ordersTabLabel => 'Commandes';

  @override
  String get postsTabLabel => 'Publications';

  @override
  String get profileTabLabel => 'Profil';

  @override
  String homeGreetingMorning(String name) {
    return 'Bonjour $name';
  }

  @override
  String homeGreetingAfternoon(String name) {
    return 'Bon après-midi $name';
  }

  @override
  String homeGreetingEvening(String name) {
    return 'Bonsoir $name';
  }

  @override
  String get homeSearchHint => 'Rechercher un plat, un pays, un vendeur...';

  @override
  String get homeFeaturedVendors => 'Vendeurs à la une';

  @override
  String get homeAvailableToday => 'Disponibles aujourd\'hui';

  @override
  String get homeNearby => 'Près de vous';

  @override
  String get homePopularDishes => 'Plats populaires';

  @override
  String get vendorOpenNow => 'Ouvert maintenant';

  @override
  String get vendorClosedToday => 'Fermé aujourd\'hui';

  @override
  String get vendorPreorderAvailable => 'Précommande disponible';

  @override
  String vendorRating(String rating, int count) {
    return '$rating ($count avis)';
  }

  @override
  String vendorDishCount(int count) {
    return '$count plats';
  }

  @override
  String vendorOrigin(String country) {
    return 'Cuisine $country';
  }

  @override
  String dishPrice(String price) {
    return '$price €';
  }

  @override
  String get dishOrderButton => 'Commander';

  @override
  String get dishPreorderButton => 'Pré-commander';

  @override
  String get dishUnavailable => 'Indisponible';

  @override
  String dishPreparationTime(String time) {
    return 'Prêt dans $time';
  }

  @override
  String get orderStatusPending => 'En attente';

  @override
  String get orderStatusAccepted => 'Acceptée';

  @override
  String get orderStatusPreparing => 'En préparation';

  @override
  String get orderStatusReady => 'Prête';

  @override
  String get orderStatusCompleted => 'Livrée';

  @override
  String get orderStatusCancelled => 'Annulée';

  @override
  String get orderStatusRejected => 'Refusée';

  @override
  String preorderAcompteInstructions(String method, String handle) {
    return 'Envoyez l\'acompte sur le compte $method du vendeur ($handle), puis uploadez la capture ci-dessous.';
  }

  @override
  String get preorderUploadCapture => 'Ajouter la capture du paiement';

  @override
  String get preorderCaptureAdded => 'Capture ajoutée';

  @override
  String get preorderSubmit => 'Envoyer ma précommande';

  @override
  String get preorderDisclaimerTitle => 'Information importante';

  @override
  String get preorderDisclaimer =>
      'CALMA ne gère pas les transactions financières. Le paiement se fait directement entre vous et le vendeur. En cas de litige, CALMA peut tenter de médiation mais ne garantit aucun remboursement.';

  @override
  String cancellationWarning(int count) {
    return 'Attention : $count annulation(s) tardive(s) enregistrée(s) sur votre profil.';
  }

  @override
  String get cancellationThresholdWarning =>
      'Votre compte sera signalé après 3 annulations tardives.';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsProfile => 'Mon profil';

  @override
  String get settingsTheme => 'Apparence';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsAbout => 'À propos';

  @override
  String get settingsLogout => 'Se déconnecter';

  @override
  String get settingsDeleteAccount => 'Supprimer mon compte';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeAccentColor => 'Couleur principale';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String get errorGeneric => 'Une erreur est survenue. Veuillez réessayer.';

  @override
  String get errorNetwork => 'Pas de connexion internet.';

  @override
  String get errorNotFound => 'Contenu introuvable.';

  @override
  String get errorUnauthorized =>
      'Vous n\'êtes pas autorisé à effectuer cette action.';

  @override
  String get errorEmailAlreadyUsed => 'Cette adresse email est déjà utilisée.';

  @override
  String get errorInvalidCredentials => 'Email ou mot de passe incorrect.';

  @override
  String get errorWeakPassword =>
      'Le mot de passe doit contenir au moins 8 caractères.';

  @override
  String get errorInvalidEmail => 'Adresse email invalide.';

  @override
  String get successProfileUpdated => 'Profil mis à jour.';

  @override
  String get successOrderPlaced => 'Commande envoyée.';

  @override
  String get successPreorderPlaced => 'Précommande envoyée.';

  @override
  String get successOrderAccepted => 'Commande acceptée.';

  @override
  String get successOrderCancelled => 'Commande annulée.';

  @override
  String get emptyStateVendors => 'Aucun vendeur disponible pour le moment.';

  @override
  String get emptyStateDishes => 'Aucun plat disponible.';

  @override
  String get emptyStateOrders => 'Vous n\'avez pas encore de commandes.';

  @override
  String get emptyStatePosts => 'Aucune publication pour le moment.';

  @override
  String get emptyStateChats => 'Aucune conversation.';

  @override
  String get deleteConfirmTitle => 'Confirmer la suppression';

  @override
  String get deleteConfirmMessage =>
      'Cette action est irréversible. Voulez-vous continuer ?';

  @override
  String get logoutConfirmTitle => 'Se déconnecter';

  @override
  String get logoutConfirmMessage => 'Voulez-vous vraiment vous déconnecter ?';

  @override
  String get referralBadgeAmbassador => 'Ambassadeur';

  @override
  String referralShareMessage(String link) {
    return 'Rejoins CALMA et trouve des plats de chez toi ! $link';
  }
}
