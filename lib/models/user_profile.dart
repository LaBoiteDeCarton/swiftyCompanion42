class User42Profile {
  final String login;
  final String displayName;
  final String email;
  final String? imageUrl;
  final String? campus;
  final double? level;
  final int wallet;
  final int correctionPoints;
  final List<Project42> recentProjects;

  User42Profile({
    required this.login,
    required this.displayName,
    required this.email,
    this.imageUrl,
    this.campus,
    this.level,
    required this.wallet,
    required this.correctionPoints,
    required this.recentProjects,
  });

  factory User42Profile.fromJson(Map<String, dynamic> json) {
    return User42Profile(
      login: json['login'] ?? '',
      displayName: json['displayname'] ?? json['login'] ?? 'Unknown User',
      email: json['email'] ?? '',
      imageUrl: json['image']?['versions']?['large'],
      campus: json['campus']?.isNotEmpty == true ? json['campus'][0]['name'] : null,
      level: json['cursus_users']?.isNotEmpty == true 
          ? (json['cursus_users'][0]['level'] as num?)?.toDouble()
          : null,
      wallet: json['wallet'] ?? 0,
      correctionPoints: json['correction_point'] ?? 0,
      recentProjects: (json['projects_users'] as List<dynamic>?)
          ?.map((project) => Project42.fromJson(project))
          .toList() ?? [],
    );
  }
}

class Project42 {
  final String name;
  final String status;
  final int? finalMark;
  final int id;

  Project42({
    required this.name,
    required this.status,
    this.finalMark,
    required this.id,
  });

  factory Project42.fromJson(Map<String, dynamic> json) {
    return Project42(
      name: json['project']?['name'] ?? 'Unknown Project',
      status: json['status'] ?? 'unknown',
      finalMark: json['final_mark'],
      id: json['id'] ?? 0,
    );
  }
}