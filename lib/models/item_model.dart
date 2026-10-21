
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final String name;
  final String username;
  final String password;
  final String role;
  bool approved;

  User({
    required this.name,
    required this.username,
    required this.password,
    required this.role,
    this.approved = false,
  });
}

class UserStore {
  static const String _key = 'task_inventory_users';
  static bool _loaded = false;

  static final List<User> users = [
    User(
      name: 'Admin',
      username: 'admin',
      password: '22072010',
      role: 'admin',
      approved: true,
    ),
  ];

  static Future<void> loadUsers() async {
    if (_loaded) return;

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);

    if (raw != null) {
      final decoded = jsonDecode(raw) as List<dynamic>;

      for (final row in decoded) {
        final data = Map<String, dynamic>.from(row as Map);
        final username = data['username'] as String;

        users.removeWhere(
          (user) =>
              user.username.toLowerCase() == username.toLowerCase(),
        );

        users.add(
          User(
            name: data['name'] as String,
            username: username,
            password: data['password'] as String,
            role: data['role'] as String,
            approved: data['approved'] == true,
          ),
        );
      }
    }

    _loaded = true;
  }

  static Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();

    final savedUsers = users
        .where(
          (user) =>
              user.username != 'user1' &&
              user.username != 'admin',
        )
        .map(
          (user) => {
            'name': user.name,
            'username': user.username,
            'password': user.password,
            'role': user.role,
            'approved': user.approved,
          },
        )
        .toList();

    await prefs.setString(_key, jsonEncode(savedUsers));
  }

  static Future<User?> login(
    String username,
    String password,
  ) async {
    await loadUsers();

    for (final user in users) {
      if (user.username.toLowerCase() ==
              username.trim().toLowerCase() &&
          user.password == password) {
        return user;
      }
    }

    return null;
  }

  static Future<String?> register({
    required String name,
    required String username,
    required String password,
  }) async {
    await loadUsers();

    final cleanName = name.trim();
    final cleanUsername = username.trim();

    if (cleanName.isEmpty || cleanUsername.isEmpty) {
      return 'nama dan username wajib diisi';
    }

    if (password.length < 6) {
      return 'password minimal 6 karakter';
    }

    if (users.any(
      (user) =>
          user.username.toLowerCase() ==
          cleanUsername.toLowerCase(),
    )) {
      return 'username sudah digunakan';
    }

    users.add(
      User(
        name: cleanName,
        username: cleanUsername,
        password: password,
        role: 'user',
        approved: false,
      ),
    );

    await _save();
    return null;
  }

  static Future<void> setApproval(
    String username,
    bool approved,
  ) async {
    await loadUsers();

    final index = users.indexWhere(
      (user) =>
          user.username.toLowerCase() ==
          username.toLowerCase(),
    );

    if (index == -1) {
      throw Exception('akun tidak ditemukan');
    }

    users[index].approved = approved;
    await _save();
  }
}

class ItemModel {
  final String id;
  final String name;
  final String category;
  final int price;
  int stock;

  ItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
  });
}