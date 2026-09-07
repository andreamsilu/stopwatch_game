/// Progress while opening a paid round (billing → target time).
enum RoundPreparePhase {
  idle,
  checkingSubscription,
  awaitingSubscription,
  charging,
  awaitingPayment,
  loadingTarget,
}
