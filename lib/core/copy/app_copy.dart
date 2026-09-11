/// User-facing copy for Gandisha Ushinde.
class AppCopy {
  AppCopy._();
}

/// Current language used by the lightweight application copy layer.
class AppLanguage {
  AppLanguage._();

  static String code = 'sw';

  static bool get isEnglish => code == 'en';

  static String pick(String swahili, String english) =>
      isEnglish ? english : swahili;
}

class AuthCopy {
  AuthCopy._();

  static String get welcomeTitle => 'Gandisha Ushinde';
  static String get welcomeSubtitle => AppLanguage.pick(
    'Unaweza kusimamisha saa katika sekunde 10.00 kamili?',
    'Think you can stop the clock at exactly 10.00 seconds?',
  );
  static String get welcomeSupport => AppLanguage.pick(
    'Simamisha saa karibu iwezekanavyo na muda lengwa, ujaribu usahihi wako.',
    'Stop the clock as close to the target as you can and test your precision.',
  );

  static String get verifyTitle =>
      AppLanguage.pick('Thibitisha namba yako', 'Verify your number');
  static String verifySubtitle(String maskedPhone) => AppLanguage.pick(
    'Weka namba ya kuthibitisha yenye tarakimu 6 iliyotumwa kwa $maskedPhone.',
    'Enter the 6-digit code sent to $maskedPhone.',
  );

  static String get phoneLabel =>
      AppLanguage.pick('Namba ya simu ya Tanzania', 'Tanzanian mobile number');
  static String get phoneHint =>
      AppLanguage.pick('Namba ya simu', 'Phone number');
  static String get phoneReassurance => AppLanguage.pick(
    'Namba yako itatumika kutambua ushiriki wako katika mchezo.',
    'Your number will be used to identify your game entry.',
  );
  static String get continueButton =>
      AppLanguage.pick('ENDELEA  →', 'CONTINUE  →');
  static String get verifyButton =>
      AppLanguage.pick('THIBITISHA NA UCHEZE  →', 'VERIFY & PLAY  →');
  static String get changeNumber =>
      AppLanguage.pick('Badilisha namba', 'Change number');
  static String get resendCode =>
      AppLanguage.pick('Tuma namba tena', 'Resend code');
  static String get resendingCode => AppLanguage.pick('Inatuma…', 'Sending…');
  static String get readyToPlay =>
      AppLanguage.pick('Uko tayari kucheza?', 'Ready to play?');
  static String get enterMobileNumber => AppLanguage.pick(
    'Weka namba yako ya simu ili uendelee.',
    'Enter your mobile number to continue.',
  );
  static String get closeLogin =>
      AppLanguage.pick('Funga sehemu ya kuingia', 'Close login');

  static String get privacyPolicy =>
      AppLanguage.pick('Sera ya Faragha', 'Privacy Policy');
  static String get termsOfService =>
      AppLanguage.pick('Masharti ya Huduma', 'Terms of Service');
  static String get contactSupport =>
      AppLanguage.pick('Wasiliana na Msaada', 'Contact Support');
  static String copyright(int year) => AppLanguage.pick(
    '© $year Gandisha Ushinde. Haki zote zimehifadhiwa.',
    '© $year Gandisha Ushinde. All rights reserved.',
  );
}

class GameCopy {
  GameCopy._();

  static String _t(String swahili, String english) =>
      AppLanguage.pick(swahili, english);

  static String get appName => 'Gandisha Ushinde';
  static String footerCopyright(int year) => _t(
    '© $year Gandisha Ushinde. Cheza kwa usahihi.',
    '© $year Gandisha Ushinde. Play with precision.',
  );
  static String get termsOfService =>
      _t('Masharti ya Huduma', 'Terms of Service');
  static String get privacyPolicy => _t('Sera ya Faragha', 'Privacy Policy');
  static String get contactSupport =>
      _t('Wasiliana na Msaada', 'Contact Support');
  static String get homeHeadline =>
      _t('Unaweza kukaribia kwa kiasi gani?', 'How close can you get?');
  static String get homeTagline => _t(
    'Simamisha kipima muda kwenye muda lengwa.',
    'Stop the timer exactly on the target time.',
  );
  static String get homeWinLine =>
      _t('Aliyekaribia zaidi hushinda raundi.', 'Closest stop wins the round.');
  static String get play => _t('Cheza', 'Play');
  static String get payForRound => _t('Cheza', 'Pay for round');
  static String get goToPlayRound => _t('Nenda kucheza', 'Go to play');

  static String get startRound => _t('Anza raundi', 'Start round');
  static String get stopRound => _t('Simamisha raundi', 'Stop round');
  static String get leaveRound => _t('Ondoka kwenye raundi', 'Leave round');
  static String get targetTime => _t('Muda lengwa', 'Target time');
  static String get perfectStops => _t('Usimamishaji sahihi', 'Perfect stops');
  static String get targetTimeBadge => _t('MUDA LENGWA', 'TARGET TIME');

  static String get enableSounds => _t('Washa sauti', 'Enable sounds');
  static String get disableSounds => _t('Zima sauti', 'Disable sounds');
  static String get soundOn => _t('Sauti imewashwa', 'Sound on');
  static String get soundOff => _t('Sauti imezimwa', 'Sound off');

  static String get roundSummary => _t('Muhtasari wa Raundi', 'Round Summary');
  static String get yourTime => _t('Muda wako', 'Your time');
  static String get timeDifference => _t('Tofauti ya muda', 'Time difference');
  static String get keepPractising =>
      _t('Endelea kufanya mazoezi!', 'Keep practising!');
  static String get playAgain => _t('CHEZA TENA', 'PLAY AGAIN');
  static String get viewHistory => _t('TAZAMA HISTORIA', 'VIEW HISTORY');
  static String get roundsStat => _t('Raundi', 'Rounds');
  static String get bestDiffStat => _t('Tofauti bora', 'Best diff');
  static String get accuracyLabel => _t('usahihi', 'accuracy');
  static String get cancel => _t('Ghairi', 'Cancel');
  static String get tryAgain => _t('Jaribu tena', 'Try again');
  static String get closeResultDialog => _t('Funga', 'Close');

  static String get loggedIn => _t('Umeingia', 'Logged in');
  static String get logOut => _t('Toka', 'Log out');
  static String get navigation => _t('Urambazaji', 'Navigation');
  static String get home => _t('Nyumbani', 'Home');
  static String get playTab => _t('Cheza', 'Play');
  static String get historyTab => _t('Historia', 'History');
  static String get howToPlayTab => _t('Jinsi ya Kucheza', 'How to Play');
  static String get supportTab => _t('Msaada', 'Support');
  static String get profileTab => _t('Wasifu', 'Profile');
  static String get openMenu => _t('Fungua menyu', 'Open menu');

  static String get historyTitle => _t('Historia', 'History');
  static String get historySubtitle =>
      _t('Raundi zako za hivi karibuni', 'Your recent rounds');
  static String get historyEmpty => _t(
    'Bado hakuna raundi. Gusa Cheza kuanza jaribio lako la kwanza.',
    'No rounds yet. Tap Play to start your first attempt.',
  );
  static String get historyRetry => _t('Jaribu tena', 'Try again');
  static String get historyColPlayed => _t('Ilichezwa', 'Played');
  static String get historyColTarget => _t('Lengo', 'Target');
  static String get historyColYourStop => _t('Ulisimamisha', 'Your stop');
  static String get historyColResult => _t('Matokeo', 'Result');
  static String get historyPreviousPage =>
      _t('Ukurasa uliopita', 'Previous page');
  static String get historyNextPage => _t('Ukurasa unaofuata', 'Next page');
  static String historyPageLabel(int page) =>
      _t('Ukurasa wa $page', 'Page $page');
  static String get historyCardTitle => _t('Historia', 'History');
  static String get historyCardSubtitle => _t(
    'Tazama raundi zako za karibuni. Fuatilia usahihi na boresha kasi yako ya kuitikia.',
    'See how your recent rounds went. Track your precision and improve your reaction time.',
  );
  static String get viewHistoryLink =>
      _t('Tazama Historia →', 'View History →');

  static String get howToPlayTitle => _t('Jinsi ya kucheza', 'How to play');
  static String get howToPlaySubtitle => _t(
    'Simamisha kipima muda karibu iwezekanavyo na muda lengwa.',
    'Stop the stopwatch as close as you can to the target time.',
  );
  static String get howToPlayTipsBody => _t(
    'Cheza raundi, kisha anza kipima muda ukiwa tayari. Kuwa makini!',
    'Pay for a round, then start the stopwatch when you are ready. Keep it steady!',
  );
  static String get learnTipsLink => _t('Jifunze Mbinu →', 'Learn Tips →');

  static String get howToPlayStep1Prefix => _t('Gusa ', 'Tap ');
  static String get howToPlayStep1Highlight =>
      _t('Cheza', 'Pay for round');
  static String get howToPlayStep1Suffix =>
      _t(' kisha uthibitishe kwenye simu yako', ' and confirm on your phone');
  static String get howToPlayStep2Prefix => _t('Gusa ', 'Tap ');
  static String get howToPlayStep2Highlight => _t('Anza raundi', 'Start round');
  static String get howToPlayStep2Suffix =>
      _t(' lengo lako linapotokea', ' when your target appears');
  static String get howToPlayStep3Prefix =>
      _t('Simamisha kipima muda — ', 'Stop the timer — ');
  static String get howToPlayStep3Highlight =>
      _t('muda unaokaribia zaidi hushinda', 'closest time wins');

  static String get perfectStop =>
      _t('Umesimamisha kikamilifu!', 'Perfect stop!');
  static String get customerCareTitle => 'YAS Customer Care';
  static String get customerCareSubtitle => _t(
    'Chagua njia inayokufaa zaidi.',
    'Choose the option that works best for you.',
  );
  static String get customerCareCall => _t('PIGA SIMU', 'CALL');
  static String get customerCareCallDetail =>
      _t('Kutoka kwenye laini yako ya YAS', 'From your YAS line');
  static String get customerCareWhatsApp => 'WHATSAPP';
  static String get customerCareWhatsAppDetail =>
      _t('Zungumza na timu ya YAS', 'Chat with YAS support');
  static String get customerCareEmail => _t('BARUA PEPE', 'EMAIL');
  static String get customerCareEmailDetail =>
      _t('Tuma swali lako', 'Send your question');
  static String get customerCareVisit => _t('TEMBELEA', 'VISIT');
  static String get customerCareStore => _t('Duka la YAS', 'YAS store');
  static String get customerCareVisitDetail =>
      _t('Pata msaada wa ana kwa ana', 'Get face-to-face support');
  static String get faqTitle => _t('Maswali na Majibu', 'Questions & Answers');
  static String get faqSubtitle => _t(
    'Majibu ya haraka kuhusu mchezo na malipo.',
    'Quick answers about the game and payments.',
  );
  static String get faqPlayQuestion =>
      _t('Ninawezaje kucheza?', 'How do I play?');
  static String get faqPlayAnswer => _t(
    'Ingia kwa namba yako ya YAS, gusa Cheza, thibitisha malipo kwenye simu yako, kisha anza na usimamishe kipima muda karibu na muda lengwa.',
    'Sign in with your YAS number, tap Play round, confirm payment on your phone, then start and stop the timer as close to the target time as possible.',
  );
  static String get faqChargeQuestion =>
      _t('Je, ninatozwa kila raundi?', 'Am I charged for every round?');
  static String get faqChargeAnswer => _t(
    'Ndiyo. Kila raundi mpya inalipiwa kupitia namba yako ya YAS, na utaombwa kuthibitisha malipo kabla ya kuanza.',
    'Yes. Every new round is paid through your YAS number, and you will be asked to confirm the payment before it begins.',
  );
  static String get faqTargetQuestion =>
      _t('Lengo la mchezo ni nini?', 'What is the objective of the game?');
  static String get faqTargetAnswer => _t(
    'Simamisha kipima muda karibu iwezekanavyo na muda lengwa unaoonyeshwa. Kadiri unavyokaribia, ndivyo matokeo yako yanavyokuwa bora.',
    'Stop the timer as close as possible to the displayed target time. The closer you get, the better your result.',
  );
  static String get faqPaymentQuestion => _t(
    'Nifanye nini malipo yasipothibitishwa?',
    'What should I do if payment is not confirmed?',
  );
  static String get faqPaymentAnswer => _t(
    'Hakikisha una salio na mtandao wa kutosha, kisha ujaribu tena. Tatizo likiendelea, wasiliana na YAS Customer Care kupitia njia zilizo hapo juu.',
    'Check that you have enough balance and a network connection, then try again. If the problem continues, contact YAS Customer Care using an option above.',
  );
  static String get faqHistoryQuestion =>
      _t('Ninaonaje matokeo yangu?', 'Where can I see my results?');
  static String get faqHistoryAnswer => _t(
    'Matokeo huonekana baada ya kila raundi. Unaweza pia kufungua Historia kuona raundi zako za hivi karibuni.',
    'Results appear after every round. You can also open History to review your recent rounds.',
  );

  static String get startingNewRound =>
      _t('Inaanza raundi mpya…', 'Starting a new round…');
  static String get startingRound => _t('Inaanza raundi…', 'Starting round…');
  static String get stoppingTimer =>
      _t('Inasimamisha kipima muda…', 'Stopping timer…');
  static String get refreshingRound => _t('Inaonyesha upya…', 'Refreshing…');
  static String get roundRefreshed => _t('Raundi iko tayari.', 'Round ready.');
  static String get refreshConfirmTitle =>
      _t('Uanze raundi mpya?', 'Start a new round?');
  static String get refreshConfirmBody => _t(
    'Kuvuta ili kuonyesha upya kutatoza namba yako tena kwa muda mpya lengwa.',
    'Pull to refresh will charge your number again for a new target time.',
  );
  static String get refreshConfirmAction => _t('Lipa tena', 'Pay again');
  static String get refreshConfirmCancel => _t('Si sasa', 'Not now');
  static String get sessionExpiredTitle =>
      _t('Kipindi kimeisha', 'Session ended');
  static String get sessionExpiredBody => _t(
    'Tafadhali ingia tena ili uendelee kucheza.',
    'Please sign in again to continue playing.',
  );
  static String get sessionExpiredAction => _t('Ingia', 'Sign in');
  static String get logoutOffline => _t(
    'Seva haikupatikana. Umetolewa kwenye kifaa hiki.',
    'Could not reach the server. You have been signed out locally.',
  );

  static String get language => _t('Lugha', 'Language');
  static String get close => _t('FUNGA', 'CLOSE');
  static String get leaveConfirmTitle =>
      _t('Uondoke kwenye raundi hii?', 'Leave this round?');
  static String get leaveConfirmBody => _t(
    'Raundi yako ya sasa itapotea ukiondoka.',
    'Your current round will be lost if you leave.',
  );
  static String get continuePlaying =>
      _t('ENDELEA KUCHEZA', 'CONTINUE PLAYING');
  static String get leaveRoundAction =>
      _t('ONDOKA KWENYE RAUNDI', 'LEAVE ROUND');
  static String get secondsUpper => _t('SEKUNDE', 'SECONDS');
  static String get timing => _t('INAPIMA MUDA...', 'TIMING...');
  static String perfectStopsCount(int count) =>
      _t('Usimamishaji Sahihi: $count', 'Perfect Stops: $count');
  static String get targetTenSeconds =>
      _t('Lengo lako ni sekunde 10.00', 'Your target is 10.00 seconds');
  static String get startWhenReady => _t(
    'Anza ukiwa tayari, kisha simamisha karibu iwezekanavyo na lengo.',
    'Start when you are ready and stop as close to the target as you can.',
  );
  static String get readyForChallenge =>
      _t('Uko tayari kujaribu bahati yako?', 'Ready for the challenge?');
  static String get payRoundInstruction => _t(
    'Cheza raundi na usimamishe kipima muda karibu iwezekanavyo na muda wa lengo.',
    'Pay for a round and stop the timer as close to the target time as you can.',
  );
  static String get waitingForPayment =>
      _t('Inasubiri uthibitisho wa malipo', 'Waiting for payment confirmation');
  static String get confirmPaymentOnPhone =>
      _t('Thibitisha malipo kwenye simu yako', 'Confirm payment on your phone');
  static String get waitingForPaymentEllipsis => _t(
    'Inasubiri uthibitisho wa malipo...',
    'Waiting for payment confirmation...',
  );
  static String get cancelWaiting => _t('GHAIRI KUSUBIRI', 'CANCEL WAITING');
  static String get tryAgainUpper => _t('JARIBU TENA', 'TRY AGAIN');
  static String get payForRoundUpper => _t('Cheza', 'PAY FOR ROUND');
  static String get stopUpper => _t('SIMAMISHA', 'STOP');
  static String get startRoundUpper => _t('ANZA RAUNDI', 'START ROUND');
  static String get yourTimeUpper => _t('MUDA WAKO', 'YOUR TIME');
  static String get targetUpper => _t('LENGO', 'TARGET');
  static String get differenceUpper => _t('TOFAUTI', 'DIFFERENCE');
  static String get paidRoundHint => _t(
    'Cheza Tena huanzisha raundi mpya ya kulipia.',
    'Play Again starts a new paid round.',
  );
  static String differenceSeconds(double seconds, String sign) =>
      '$sign${seconds.toStringAsFixed(3)} ${_t('sek', 'sec')}';
  static String feedback(int milliseconds) {
    final distance = milliseconds.abs();
    if (distance <= 5) return _t('KAMILI! 🎯', 'PERFECT! 🎯');
    if (distance <= 20) {
      return _t(
        'Ajabu! Umeachwa na sekunde 0.01 tu.',
        'Incredible! Only 0.01s away.',
      );
    }
    if (distance <= 75) return _t('Ulikaribia sana!', 'So close!');
    return _t('Jaribio zuri!', 'Nice try!');
  }
}
