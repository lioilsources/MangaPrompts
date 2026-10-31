/// Quota of the signed-in user (`GET /api/me`, the fields Restyler reads; the
/// payload also lists credit packages, which belong to Tsumiki).
class Account {
  const Account({
    required this.credits,
    required this.freeRemaining,
    required this.freeLimit,
  });

  final int credits;
  final int freeRemaining;
  final int freeLimit;

  int get totalRemaining => credits + freeRemaining;

  factory Account.fromJson(Map<String, dynamic> json) => Account(
    credits: json['credits'] as int,
    freeRemaining: json['free_remaining'] as int,
    freeLimit: json['free_limit'] as int,
  );
}
