class ApiEndpoints {
  ApiEndpoints._();

  static const String categories = 'category/all';

  static const String requestOtp = 'auth/getOTP';
  static const String login = 'auth/login';

  static const String listingFeed = 'listing/feed';

  static String listingDetails(Object listingId) => 'listing/$listingId';
}
