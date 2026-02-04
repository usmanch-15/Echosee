// lib/data/models/user_model.dart
class User {
  final String id;
  final String name;
  final String email;
  final String? profileImage;
  final DateTime createdAt;
  final bool isPremium;
  final DateTime? premiumExpiry;
  final Map<String, dynamic> preferences;
  final UsageStats usageStats;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    required this.createdAt,
    this.isPremium = false,
    this.premiumExpiry,
    required this.preferences,
    required this.usageStats,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profileImage: json['profileImage'],
      createdAt: DateTime.parse(json['createdAt']),
      isPremium: json['isPremium'],
      premiumExpiry: json['premiumExpiry'] != null
          ? DateTime.parse(json['premiumExpiry'])
          : null,
      preferences: Map<String, dynamic>.from(json['preferences']),
      usageStats: UsageStats.fromJson(json['usageStats']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'createdAt': createdAt.toIso8601String(),
      'isPremium': isPremium,
      'premiumExpiry': premiumExpiry?.toIso8601String(),
      'preferences': preferences,
      'usageStats': usageStats.toJson(),
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImage,
    DateTime? createdAt,
    bool? isPremium,
    DateTime? premiumExpiry,
    Map<String, dynamic>? preferences,
    UsageStats? usageStats,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      isPremium: isPremium ?? this.isPremium,
      premiumExpiry: premiumExpiry ?? this.premiumExpiry,
      preferences: preferences ?? this.preferences,
      usageStats: usageStats ?? this.usageStats,
    );
  }

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }

  bool get isPremiumActive {
    if (!isPremium) return false;
    if (premiumExpiry == null) return true;
    return premiumExpiry!.isAfter(DateTime.now());
  }

  Duration? get remainingPremiumTime {
    if (!isPremium || premiumExpiry == null) return null;
    return premiumExpiry!.difference(DateTime.now());
  }
}

class UsageStats {
  final int totalTranscripts;
  final int totalMinutes;
  final int languagesUsed;
  final DateTime lastActive;
  final Map<String, int> languageDistribution;
  final Map<String, int> dailyUsage;

  UsageStats({
    required this.totalTranscripts,
    required this.totalMinutes,
    required this.languagesUsed,
    required this.lastActive,
    required this.languageDistribution,
    required this.dailyUsage,
  });

  factory UsageStats.fromJson(Map<String, dynamic> json) {
    return UsageStats(
      totalTranscripts: json['totalTranscripts'],
      totalMinutes: json['totalMinutes'],
      languagesUsed: json['languagesUsed'],
      lastActive: DateTime.parse(json['lastActive']),
      languageDistribution: Map<String, int>.from(json['languageDistribution']),
      dailyUsage: Map<String, int>.from(json['dailyUsage']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalTranscripts': totalTranscripts,
      'totalMinutes': totalMinutes,
      'languagesUsed': languagesUsed,
      'lastActive': lastActive.toIso8601String(),
      'languageDistribution': languageDistribution,
      'dailyUsage': dailyUsage,
    };
  }

  String get formattedTotalTime {
    if (totalMinutes < 60) {
      return '$totalMinutes minutes';
    }
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return '$hours hours ${minutes} minutes';
  }

  double get averageDailyMinutes {
    if (dailyUsage.isEmpty) return 0;
    final total = dailyUsage.values.reduce((a, b) => a + b);
    return total / dailyUsage.length;
  }
}