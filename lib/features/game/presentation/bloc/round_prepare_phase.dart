/// Progress while opening a paid round (billing → target time).
enum RoundPreparePhase {
  idle,
  charging,
  loadingTarget,
}
