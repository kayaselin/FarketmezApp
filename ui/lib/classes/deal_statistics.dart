class CampaignStatistics {
  int statisticId;
  int campaignId;
  int totalUses;
  

  CampaignStatistics({
    required this.statisticId,
    required this.campaignId,
    required this.totalUses,
    
    
  });

  factory CampaignStatistics.fromJson(Map<String, dynamic> json) {
    return CampaignStatistics(
      statisticId: json['statistic_id'],
      campaignId: json['campaign_id'],
      totalUses: json['total_uses'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statistic_id': statisticId,
      'campaign_id': campaignId,
      'total_uses': totalUses,
    };
  }
}
