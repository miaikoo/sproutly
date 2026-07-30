class AppRoutes {
  static const landing = '/';
  static const login = '/login';
  static const register = '/register';

  // Bottom Navigation
  static const home = '/home';
  static const board = '/board';
  static const buddy = '/buddy';

  // Others
  static const profile = '/profile';
  static const childProfile = '/profile/:childId';

  static String childProfilePath(String childId) => '/profile/$childId';
  static const settings = '/settings';

  static const boardDetail = '/board/detail/:id';
  static const runBoard = '/board/run/:id';
  static const activity = '/activity/:scheduleId/:activityId';

  static String boardDetailPath(String id) => '/board/detail/$id';
  static String runBoardPath(String id) => '/board/run/$id';
  static String activityPath(String scheduleId, String activityId) =>
      '/activity/$scheduleId/$activityId';

  // Create board
  static const createBoard = '/board/create';
  static const createBoardActivity = '/board/create/activity';
  static const createScheduleBoard = '/board/create/schedule';
  static const createActivity = '/board/create/activity-detail';
  static const createFirstThenBoard = '/board/create/first-then';
  static const String createWaitingBoard = '/create-waiting-board';
  static const String createEmotionBoard = '/create-emotion-board';

  static const analytics = '/analytics';
  static const report = '/analytics/report';

  static const therapist = '/therapist';
}