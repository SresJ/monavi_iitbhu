/// Dashboard statistics model
class DashboardStats {
  final int totalPatients;
  final int totalAnalyses;
  final int recentAnalysesCount;  // Last 7 days

  DashboardStats({
    required this.totalPatients,
    required this.totalAnalyses,
    required this.recentAnalysesCount,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalPatients: json['total_patients'] as int? ?? 0,
      totalAnalyses: json['total_analyses'] as int? ?? 0,
      recentAnalysesCount: json['recent_analyses_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_patients': totalPatients,
      'total_analyses': totalAnalyses,
      'recent_analyses_count': recentAnalysesCount,
    };
  }
}
