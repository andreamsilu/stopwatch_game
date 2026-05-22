/// User-facing copy for Stopwatch Challenge.
class AppCopy {
  AppCopy._();
}

class AuthCopy {
  AuthCopy._();

  static const welcomeTitle = 'Welcome';
  static const welcomeSubtitle = 'Log in with your mobile number to play.';

  static const verifyTitle = 'Verify your number';
  static String verifySubtitle(String maskedPhone) =>
      'Enter the 6-digit code sent to $maskedPhone.';

  static const phoneLabel = 'Phone number';
  static const phoneHint = '712 345 678';
  static const continueButton = 'Continue';
  static const changeNumber = 'Change number';
  static const resendCode = 'Resend code';
  static const resendingCode = 'Sending…';

  static const privacyPolicy = 'Privacy Policy';
  static const termsOfService = 'Terms of Service';
  static const contactSupport = 'Contact Support';
  static String copyright(int year) =>
      '© $year Chrono Precision. All rights reserved.';
}

class GameCopy {
  GameCopy._();

  static const appName = 'Stopwatch Challenge';
  static String footerCopyright(int year) =>
      '© $year Stopwatch Challenge. Play with precision.';
  static const termsOfService = 'Terms of Service';
  static const privacyPolicy = 'Privacy Policy';
  static const contactSupport = 'Contact Support';
  static const followUs = 'Follow us';
  static String socialLinkOpenFailed(String platform) =>
      'Could not open $platform. Check the link and try again.';
  static const homeHeadline = 'How close can you get?';
  static const homeTagline = 'Stop the timer exactly on the target time.';
  static const homeWinLine = 'Closest stop wins the round.';
  static const play = 'Play';
  static const payForRound = 'Pay for round';
  static const goToPlayRound = 'Go to play';

  static const startRound = 'Start round';
  static const stopRound = 'Stop round';
  static const leaveRound = 'Leave round';
  static const targetTime = 'Target time';
  static const perfectStops = 'Perfect stops';
  static const targetTimeBadge = 'TARGET TIME';

  static const enableSounds = 'Enable sounds';
  static const disableSounds = 'Disable sounds';
  static const soundOn = 'Sound on';
  static const soundOff = 'Sound off';

  static const roundSummary = 'Round Summary';
  static const yourTime = 'Your time';
  static const timeDifference = 'Time difference';
  static const keepPractising = 'Keep practising!';
  static const playAgain = 'Play again';
  static const roundsStat = 'Rounds';
  static const bestDiffStat = 'Best diff';
  static const accuracyLabel = 'accuracy';
  static const cancel = 'Cancel';
  static const tryAgain = 'Try again';
  static const closeResultDialog = 'Close';

  static const loggedIn = 'Logged in';
  static const logOut = 'Log out';
  static const navigation = 'Navigation';
  static const home = 'Home';
  static const playTab = 'Play';
  static const historyTab = 'History';
  static const supportTab = 'Support';
  static const openMenu = 'Open menu';

  static const historyTitle = 'History';
  static const historySubtitle = 'Your recent rounds';
  static const historyEmpty =
      'No rounds yet. Tap Play to start your first attempt.';
  static const historyRetry = 'Try again';
  static const historyColPlayed = 'Played';
  static const historyColTarget = 'Target';
  static const historyColYourStop = 'Your stop';
  static const historyColResult = 'Result';
  static const historyPreviousPage = 'Previous page';
  static const historyNextPage = 'Next page';
  static String historyPageLabel(int page) => 'Page $page';
  static const historyCardTitle = 'History';
  static const historyCardSubtitle =
      'See how your recent rounds went. Track your precision and improve your reaction time.';
  static const viewHistoryLink = 'View History →';

  static const howToPlayTitle = 'How to play';
  static const howToPlaySubtitle =
      'Stop the stopwatch as close as you can to the target time.';
  static const howToPlayTipsBody =
      'Pay for a round, then start the stopwatch when you are ready. Keep it steady!';
  static const learnTipsLink = 'Learn Tips →';

  static const howToPlayStep1Prefix = 'Tap ';
  static const howToPlayStep1Highlight = 'Pay for round';
  static const howToPlayStep1Suffix = ' and confirm on your phone';
  static const howToPlayStep2Prefix = 'Tap ';
  static const howToPlayStep2Highlight = 'Start round';
  static const howToPlayStep2Suffix = ' when your target appears';
  static const howToPlayStep3Prefix = 'Stop the timer — ';
  static const howToPlayStep3Highlight = 'closest time wins';

  static const helpTitle = 'Help & Support';
  static const helpIntro =
      'Need help with Stopwatch Challenge? Use the options below.';
  static const helpHowToPlayTitle = 'How to play';
  static const helpHowToPlayBody =
      'Pay for round → Start round → Stop as close to the target time as you can.';

  static const perfectStop = 'Perfect stop!';
  static const helpReportTitle = 'Report an issue';
  static const helpReportBody =
      'Tell us about bugs or anything that did not work as expected.';
  static const helpContactTitle = 'Contact support';
  static const helpContactBody = 'Email: support@stopwatchchallenge.app';

  static const startingNewRound = 'Starting a new round…';
  static const startingRound = 'Starting round…';
  static const stoppingTimer = 'Stopping timer…';
  static const refreshingRound = 'Refreshing…';
  static const roundRefreshed = 'Round ready.';
  static const refreshConfirmTitle = 'Start a new round?';
  static const refreshConfirmBody =
      'Pull to refresh will charge your number again for a new target time.';
  static const refreshConfirmAction = 'Pay again';
  static const refreshConfirmCancel = 'Not now';
  static const sessionExpiredTitle = 'Session ended';
  static const sessionExpiredBody =
      'Please sign in again to continue playing.';
  static const sessionExpiredAction = 'Sign in';
  static const logoutOffline =
      'Could not reach the server. You have been signed out locally.';
}
