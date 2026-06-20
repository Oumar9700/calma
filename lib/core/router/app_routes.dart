abstract class AppRoutes {
  // Auth
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyEmail = '/verify-email';
  static const String forgotPassword = '/forgot-password';
  static const String roleSelection = '/role-selection';

  // Shell (bottom nav)
  static const String shell = '/app';
  static const String home = '/app/home';
  static const String explore = '/app/explore';
  static const String orders = '/app/orders';
  static const String posts = '/app/posts';
  static const String profile = '/app/profile';

  // Vendor
  static const String vendorProfile = '/vendor/:vendorId';
  static const String vendorDashboard = '/app/vendor/dashboard';
  static const String vendorDishes = '/app/vendor/dishes';
  static const String vendorAddDish = '/app/vendor/dishes/add';
  static const String vendorEditDish = '/app/vendor/dishes/:dishId/edit';
  static const String vendorOrders = '/app/vendor/orders';
  static const String vendorSchedule = '/app/vendor/schedule';

  // Dish / Order
  static const String dishDetail = '/dish/:dishId';
  static const String orderDetail = '/app/orders/:orderId';
  static const String preorderCreate = '/dish/:dishId/preorder';
  static const String orderCreate = '/dish/:dishId/order';
  static const String orderConfirmation = '/app/orders/:orderId/confirmation';

  // Chat
  static const String chat = '/app/chat/:chatId';
  static const String chatList = '/app/chats';

  // Settings
  static const String settings = '/app/settings';
  static const String editProfile = '/app/settings/profile';
  static const String themeSettings = '/app/settings/theme';
  static const String languageSettings = '/app/settings/language';
  static const String notificationSettings = '/app/settings/notifications';
}
