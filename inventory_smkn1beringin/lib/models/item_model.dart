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

  // Akun admin super utama.
  static final List<User> users = [
    User(
      name: 'Admin',
      username: 'admin',
      password: '22072010',
      role: 'super_admin',
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

        // Akun utama admin tidak boleh ditimpa data tersimpan.
        if (username.toLowerCase() == 'admin') continue;

        users.removeWhere(
          (user) =>
              user.username.toLowerCase() ==
              username.toLowerCase(),
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
              user.username.toLowerCase() != 'admin' &&
              user.username.toLowerCase() != 'user1',
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
        if (!user.approved) return null;
        return user;
      }
    }

    return null;
  }

  // Role dapat berupa 'user' atau 'admin'.
  // Semua akun baru harus menunggu persetujuan.
  static Future<String?> register({
    required String name,
    required String username,
    required String password,
    String role = 'user',
  }) async {
    await loadUsers();

    final cleanName = name.trim();
    final cleanUsername = username.trim();
    final cleanRole = role.trim();

    if (cleanName.isEmpty || cleanUsername.isEmpty) {
      return 'nama dan username wajib diisi';
    }

    if (cleanUsername.contains(' ')) {
      return 'username tidak boleh memakai spasi';
    }

    if (password.length < 6) {
      return 'password minimal 6 karakter';
    }

    if (cleanRole != 'user' && cleanRole != 'admin') {
      return 'role pendaftaran tidak valid';
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
        role: cleanRole,
        approved: false,
      ),
    );

    await _save();
    return null;
  }

  // Hanya akun user/admin yang bisa disetujui.
  // Akun admin super tidak dapat diubah melalui fungsi ini.
  static Future<void> setApproval(
    String username,
    bool approved,
  ) async {
    await loadUsers();

    final index = users.indexWhere(
      (user) =>
          user.username.toLowerCase() ==
              username.toLowerCase() &&
          (user.role == 'user' || user.role == 'admin'),
    );

    if (index == -1) {
      throw Exception('akun tidak ditemukan');
    }

    users[index].approved = approved;
    await _save();
  }

  // Menolak akun user/admin yang masih menunggu persetujuan.
  static Future<void> rejectUser(String username) async {
    await loadUsers();

    users.removeWhere(
      (user) =>
          user.username.toLowerCase() ==
              username.toLowerCase() &&
          (user.role == 'user' || user.role == 'admin') &&
          !user.approved,
    );

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