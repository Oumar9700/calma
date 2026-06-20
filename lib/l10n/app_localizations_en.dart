// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'CALMA';

  @override
  String get appTagline => 'Just Like Home';

  @override
  String get continueAction => 'Continue';

  @override
  String get skipAction => 'Skip';

  @override
  String get saveAction => 'Save';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get deleteAction => 'Delete';

  @override
  String get editAction => 'Edit';

  @override
  String get confirmAction => 'Confirm';

  @override
  String get backAction => 'Back';

  @override
  String get retryAction => 'Retry';

  @override
  String get closeAction => 'Close';

  @override
  String get yesAction => 'Yes';

  @override
  String get noAction => 'No';

  @override
  String get sendAction => 'Send';

  @override
  String get searchAction => 'Search';

  @override
  String get filterAction => 'Filter';

  @override
  String get seeAllAction => 'See all';

  @override
  String get loadMoreAction => 'Load more';

  @override
  String get onboardingTitle1 => 'Dishes that remind you of home';

  @override
  String get onboardingSubtitle1 =>
      'Find meals lovingly prepared by fellow students.';

  @override
  String get onboardingTitle2 => 'Share your cuisine';

  @override
  String get onboardingSubtitle2 =>
      'Sell dishes from your country and share your culture.';

  @override
  String get onboardingTitle3 => 'Order easily';

  @override
  String get onboardingSubtitle3 => 'Order or pre-order in just a few taps.';

  @override
  String get getStarted => 'Get Started';

  @override
  String get alreadyHaveAccount => 'I already have an account';

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in to your account';

  @override
  String get emailLabel => 'Email address';

  @override
  String get emailHint => 'your@email.com';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'Your password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get loginButton => 'Sign in';

  @override
  String get noAccountYet => 'No account yet?';

  @override
  String get signUpLink => 'Sign up';

  @override
  String get orWith => 'Or with';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get registerTitle => 'Create an account';

  @override
  String get registerSubtitle => 'Join the CALMA community';

  @override
  String get firstNameLabel => 'First name';

  @override
  String get lastNameLabel => 'Last name';

  @override
  String get phoneLabel => 'Phone (optional)';

  @override
  String get registerButton => 'Create my account';

  @override
  String get alreadyHaveAccountLogin => 'Already have an account?';

  @override
  String get loginLink => 'Sign in';

  @override
  String get termsAgreement => 'By signing up, you agree to our ';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get andThe => ' and the ';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get roleSelectionTitle => 'How would you like to use CALMA?';

  @override
  String get roleBuyer => 'Buyer';

  @override
  String get roleBuyerDescription => 'I\'m looking for homemade meals';

  @override
  String get roleVendor => 'Vendor';

  @override
  String get roleVendorDescription => 'I want to cook and sell my dishes';

  @override
  String get roleBoth => 'Both';

  @override
  String get roleBothDescription => 'I want to buy and sell';

  @override
  String get homeTabLabel => 'Home';

  @override
  String get exploreTabLabel => 'Explore';

  @override
  String get ordersTabLabel => 'Orders';

  @override
  String get postsTabLabel => 'Posts';

  @override
  String get profileTabLabel => 'Profile';

  @override
  String homeGreetingMorning(String name) {
    return 'Good morning, $name';
  }

  @override
  String homeGreetingAfternoon(String name) {
    return 'Good afternoon, $name';
  }

  @override
  String homeGreetingEvening(String name) {
    return 'Good evening, $name';
  }

  @override
  String get homeSearchHint => 'Search for a dish, country, vendor...';

  @override
  String get homeFeaturedVendors => 'Featured vendors';

  @override
  String get homeAvailableToday => 'Available today';

  @override
  String get homeNearby => 'Near you';

  @override
  String get homePopularDishes => 'Popular dishes';

  @override
  String get vendorOpenNow => 'Open now';

  @override
  String get vendorClosedToday => 'Closed today';

  @override
  String get vendorPreorderAvailable => 'Pre-order available';

  @override
  String vendorRating(String rating, int count) {
    return '$rating ($count reviews)';
  }

  @override
  String vendorDishCount(int count) {
    return '$count dishes';
  }

  @override
  String vendorOrigin(String country) {
    return '$country cuisine';
  }

  @override
  String dishPrice(String price) {
    return '€$price';
  }

  @override
  String get dishOrderButton => 'Order';

  @override
  String get dishPreorderButton => 'Pre-order';

  @override
  String get dishUnavailable => 'Unavailable';

  @override
  String dishPreparationTime(String time) {
    return 'Ready in $time';
  }

  @override
  String get orderStatusPending => 'Pending';

  @override
  String get orderStatusAccepted => 'Accepted';

  @override
  String get orderStatusPreparing => 'Preparing';

  @override
  String get orderStatusReady => 'Ready';

  @override
  String get orderStatusCompleted => 'Completed';

  @override
  String get orderStatusCancelled => 'Cancelled';

  @override
  String get orderStatusRejected => 'Rejected';

  @override
  String preorderAcompteInstructions(String method, String handle) {
    return 'Send the deposit to the vendor\'s $method account ($handle), then upload the screenshot below.';
  }

  @override
  String get preorderUploadCapture => 'Add payment screenshot';

  @override
  String get preorderCaptureAdded => 'Screenshot added';

  @override
  String get preorderSubmit => 'Submit my pre-order';

  @override
  String get preorderDisclaimerTitle => 'Important notice';

  @override
  String get preorderDisclaimer =>
      'CALMA does not handle financial transactions. Payment is made directly between you and the vendor. In case of dispute, CALMA may attempt mediation but does not guarantee any refund.';

  @override
  String cancellationWarning(int count) {
    return 'Warning: $count late cancellation(s) recorded on your profile.';
  }

  @override
  String get cancellationThresholdWarning =>
      'Your account will be flagged after 3 late cancellations.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsProfile => 'My profile';

  @override
  String get settingsTheme => 'Appearance';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsLogout => 'Sign out';

  @override
  String get settingsDeleteAccount => 'Delete my account';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get themeAccentColor => 'Accent color';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorNetwork => 'No internet connection.';

  @override
  String get errorNotFound => 'Content not found.';

  @override
  String get errorUnauthorized =>
      'You are not authorized to perform this action.';

  @override
  String get errorEmailAlreadyUsed => 'This email address is already in use.';

  @override
  String get errorInvalidCredentials => 'Incorrect email or password.';

  @override
  String get errorWeakPassword => 'Password must be at least 8 characters.';

  @override
  String get errorInvalidEmail => 'Invalid email address.';

  @override
  String get successProfileUpdated => 'Profile updated.';

  @override
  String get successOrderPlaced => 'Order sent.';

  @override
  String get successPreorderPlaced => 'Pre-order sent.';

  @override
  String get successOrderAccepted => 'Order accepted.';

  @override
  String get successOrderCancelled => 'Order cancelled.';

  @override
  String get emptyStateVendors => 'No vendors available right now.';

  @override
  String get emptyStateDishes => 'No dishes available.';

  @override
  String get emptyStateOrders => 'You have no orders yet.';

  @override
  String get emptyStatePosts => 'No posts yet.';

  @override
  String get emptyStateChats => 'No conversations.';

  @override
  String get deleteConfirmTitle => 'Confirm deletion';

  @override
  String get deleteConfirmMessage =>
      'This action cannot be undone. Do you want to continue?';

  @override
  String get logoutConfirmTitle => 'Sign out';

  @override
  String get logoutConfirmMessage => 'Are you sure you want to sign out?';

  @override
  String get referralBadgeAmbassador => 'Ambassador';

  @override
  String referralShareMessage(String link) {
    return 'Join CALMA and find dishes from home! $link';
  }
}
