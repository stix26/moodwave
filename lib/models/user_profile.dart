import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? avatarUrl;
  final Map<String, dynamic>? metadata;
  final DateTime? lastSignInAt;
  final DateTime? createdAt;
  final List<String>? providers;

  const UserProfile({
    required this.id,
    required this.email,
    this.name,
    this.avatarUrl,
    this.metadata,
    this.lastSignInAt,
    this.createdAt,
    this.providers,
  });

  UserProfile copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    Map<String, dynamic>? metadata,
    DateTime? lastSignInAt,
    DateTime? createdAt,
    List<String>? providers,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      metadata: metadata ?? this.metadata,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
      createdAt: createdAt ?? this.createdAt,
      providers: providers ?? this.providers,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar_url': avatarUrl,
      'metadata': metadata,
      'last_sign_in_at': lastSignInAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'providers': providers,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      avatarUrl: json['avatar_url'],
      metadata: json['metadata'],
      lastSignInAt: json['last_sign_in_at'] != null
          ? DateTime.parse(json['last_sign_in_at'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      providers: json['providers'] != null
          ? List<String>.from(json['providers'])
          : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        avatarUrl,
        metadata,
        lastSignInAt,
        createdAt,
        providers,
      ];

  @override
  String toString() {
    return 'UserProfile(id: $id, email: $email, name: $name)';
  }
}
