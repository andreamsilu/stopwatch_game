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
  static const homeTagline = 'Stop as close as you can to the target time.';
  static const play = 'Play';

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
  static const timeDifference = 'Time difference';
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
  static const historyCardTitle = 'History';
  static const historyCardSubtitle = 'See how your recent rounds went';

  static const howToPlayTitle = 'How to play';
  static const howToPlaySubtitle =
      'Start the timer, follow the beat, and stop on the target.';
  static const howToPlayCardSubtitle =
      'Start the timer, follow the beat, and stop on the target.';

  static const helpTitle = 'Help & Support';
  static const helpIntro =
      'Need help with Stopwatch Challenge? Use the options below.';
  static const helpHowToPlayTitle = 'How to play';
  static const helpHowToPlayBody =
      'Start a round, run the timer, and stop as close to the target as you can.';

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
  static const logoutOffline =
      'Could not reach the server. You have been signed out locally.';
}
