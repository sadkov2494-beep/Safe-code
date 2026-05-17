enum RewardedAdPlacement { extraHint, extraAttempt, skipLevel }

class AdService {
  const AdService();

  Future<bool> showRewardedAd(RewardedAdPlacement placement) async {
    // Stub for future rewarded ads. The MVP grants the reward immediately.
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return true;
  }
}
