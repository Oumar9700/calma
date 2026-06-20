abstract class AppConstants {
  static const String appName = 'CALMA';
  static const String appTagline = 'Comme À La Maison';
  static const String deepLinkScheme = 'calma';
  static const String deepLinkHost = 'app.calma.fr';

  // Firestore collections
  static const String usersCollection = 'users';
  static const String vendorsCollection = 'vendors';
  static const String dishesCollection = 'dishes';
  static const String ordersCollection = 'orders';
  static const String preordersCollection = 'preorders';
  static const String chatsCollection = 'chats';
  static const String messagesCollection = 'messages';
  static const String ratingsCollection = 'ratings';
  static const String postsCollection = 'posts';
  static const String referralsCollection = 'referrals';
  static const String notificationsCollection = 'notifications';

  // Storage paths
  static const String usersStoragePath = 'users';
  static const String dishesStoragePath = 'dishes';
  static const String ordersStoragePath = 'orders';

  // Pagination
  static const int defaultPageSize = 20;

  // Business rules
  static const int minVendorDaysPerWeek = 2;
  static const int cancellationWarningThreshold = 3;
  static const int referralBoostDays = 7;
  static const double defaultAcomptePercent = 0.5;
}
