class FirebaseConstants {
  FirebaseConstants._();

  // Firestore collections
  static const String usersCollection = 'users';
  static const String startupsCollection = 'startups';
  static const String opportunitiesCollection = 'opportunities';
  static const String applicationsCollection = 'applications';
  static const String notificationsCollection = 'notifications';
  static const String chatsCollection = 'chats';
  static const String messagesSubcollection = 'messages';
  static const String bookmarksCollection = 'bookmarks';
  static const String verificationRequestsCollection = 'verification_requests';
  static const String adminActionsCollection = 'admin_actions';

  // Storage paths
  static const String profileImagesPath = 'profile_images';
  static const String startupLogosPath = 'startup_logos';
  static const String startupBannersPath = 'startup_banners';
  static const String resumesPath = 'resumes';
  static const String verificationDocsPath = 'verification_docs';

  // Firestore field names
  static const String fieldCreatedAt = 'createdAt';
  static const String fieldUpdatedAt = 'updatedAt';
  static const String fieldUserId = 'userId';
  static const String fieldStartupId = 'startupId';
  static const String fieldStatus = 'status';
  static const String fieldIsActive = 'isActive';
}
