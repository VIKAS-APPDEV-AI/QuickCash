class ReferralAndEarnResponse {
  final String? referralCode;
  final String? status;

  ReferralAndEarnResponse({
    this.referralCode,
    this.status,
  });

  factory ReferralAndEarnResponse.fromJson(Map<String, dynamic> json) {
    // Assuming that 'data' is an array and you're interested in the first item
    var data = json['data'] != null && json['data'].isNotEmpty ? json['data'][0] : null;

    return ReferralAndEarnResponse(
      referralCode: data?['referral_code'] as String?,
      status: data?['status'] as String?,
    );
  }
}
