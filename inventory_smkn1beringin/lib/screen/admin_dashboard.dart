import 'package:flutter/material.dart';

import '../models/item_model.dart';
import 'login_screen.dart';
import 'add_item_screen.dart';
import 'user_dashboard.dart' as dashboard;

const Color adminPink = Color(0xffe937bc);

class AdminDashboard extends StatefulWidget {
  final User user;

  const AdminDashboard({
    super.key,
    required this.user,
  });

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int selectedIndex = 0;

  bool get isSuperAdmin => widget.user.role == 'super_admin';

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = isSuperAdmin
        ? [
            _buildHome(),
            _buildTasks(),
            _buildInventory(),
            _buildUsers(),
            _buildProfile(),
          ]
        : [
            _buildHome(),
            _buildTasks(),
            _buildInventory(),
            _buildProfile(),
          ];

    // Mencegah indeks halaman tidak sesuai dengan menu admin biasa.
    final int safeIndex = selectedIndex < pages.length
        ? selectedIndex
        : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: adminPink,
        foregroundColor: Colors.white,
      ),
      body: IndexedStack(
        index: safeIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: safeIndex,
        selectedItemColor: adminPink,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() => selectedIndex = index);
        },
        items: isSuperAdmin
            ? const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Beranda',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.task_alt),
                  label: 'Task',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.inventory_2),
                  label: 'Barang',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people),
                  label: 'Pengguna',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profil',
                ),
              ]
            : const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Beranda',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.task_alt),
                  label: 'Task',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.inventory_2),
                  label: 'Barang',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profil',
                ),
              ],
      ),
    );
  }

  Widget _buildLogo({double height = 90}) {
    return Image.asset(
      'assets/images/logo_sekolah.png',
      height: height,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.school,
          size: height,
          color: adminPink,
        );
      },
    );
  }

  Widget _buildHome() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(child: _buildLogo(height: 100)),
        const SizedBox(height: 12),
        const Center(
          child: Text(
            'SMKN 1 Beringin',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Center(
          child: Text(
            'Selamat datang, ${widget.user.name}!',
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _statCard(
                'Total Task',
                dashboard.taskList.length.toString(),
                Icons.task_alt,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                'Total Barang',
                dashboard.itemList.length.toString(),
                Icons.inventory_2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Menu Admin',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        _menuCard(
          Icons.task_alt,
          'Kelola Task',
          'Tambah, tandai selesai, dan hapus task',
          () => setState(() => selectedIndex = 1),
        ),
        _menuCard(
          Icons.inventory_2,
          'Kelola Barang',
          'Lihat, tambah, dan hapus barang',
          () => setState(() => selectedIndex = 2),
        ),
        if (isSuperAdmin)
          _menuCard(
            Icons.people,
            'Kelola Pengguna',
            'Lihat, setujui, atau tolak akun pengguna',
            () => setState(() => selectedIndex = 3),
          ),
        _menuCard(
          Icons.person,
          'Biodata Admin',
          'Lihat informasi akun admin',
          () => setState(
            () => selectedIndex = isSuperAdmin ? 4 : 3,
          ),
        ),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: adminPink),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _menuCard(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: adminPink.withAlpha(30),
          child: Icon(icon, color: adminPink),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  // ==================== TASK ====================

  Widget _buildTasks() {
    return Scaffold(
      body: dashboard.taskList.isEmpty
          ? const Center(
              child: Text('Belum ada task. Tekan + untuk menambah.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: dashboard.taskList.length,
              itemBuilder: (context, index) {
                final task = dashboard.taskList[index];

                return Card(
                  child: ListTile(
                    leading: Icon(
                      task.completed
                          ? Icons.check_circle
                          : Icons.pending_actions,
                      color: adminPink,
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration: task.completed
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    subtitle: Text(task.time),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          activeColor: adminPink,
                          value: task.completed,
                          onChanged: (value) {
                            setState(() {
                              task.completed = value ?? false;
                            });
                          },
                        ),
                        IconButton(
                          tooltip: 'Hapus task',
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                title: const Text('Konfirmasi Hapus Task'),
                                content: Text(
                                  'Yakin ingin menghapus task "${task.title}"?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(dialogContext, false);
                                    },
                                    child: const Text('Batal'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(dialogContext, true);
                                    },
                                    child: const Text('Hapus'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true && mounted) {
                              setState(() {
                                dashboard.taskList.remove(task);
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Task berhasil dihapus.'),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: adminPink,
        foregroundColor: Colors.white,
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddTaskDialog() async {
    final titleController = TextEditingController();
    final timeController = TextEditingController();

    try {
      final result = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Tambah Task'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Nama task',
                      hintText: 'Contoh: Kerjakan tugas Flutter',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: timeController,
                    decoration: const InputDecoration(
                      labelText: 'Waktu task',
                      hintText: 'Contoh: 08:00–10:00',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: adminPink,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  if (titleController.text.trim().isEmpty ||
                      timeController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text('Nama dan waktu task wajib diisi.'),
                      ),
                    );
                    return;
                  }

                  Navigator.pop(dialogContext, true);
                },
                child: const Text('Simpan'),
              ),
            ],
          );
        },
      );

      if (!mounted || result != true) return;

      final title = titleController.text.trim();
      final time = timeController.text.trim();

      setState(() {
        dashboard.taskList.add(
          dashboard.TaskData(
            title: title,
            time: time,
          ),
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task berhasil ditambahkan!'),
        ),
      );
    } finally {
      titleController.dispose();
      timeController.dispose();
    }
  }

  // ==================== BARANG ====================

  Widget _buildInventory() {
    return Scaffold(
      body: dashboard.itemList.isEmpty
          ? const Center(child: Text('Belum ada barang.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: dashboard.itemList.length,
              itemBuilder: (context, index) {
                final item = dashboard.itemList[index];

                return Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.inventory_2,
                      color: adminPink,
                    ),
                    title: Text(item.name),
                    subtitle: Text(
                      '${item.category}\n'
                      'Harga: Rp${item.price} | Stok: ${item.stock}',
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text('Hapus Barang'),
                            content: Text(
                              'Yakin ingin menghapus ${item.name}?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext, false);
                                },
                                child: const Text('Batal'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext, true);
                                },
                                child: const Text('Hapus'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true && mounted) {
                          setState(() {
                            dashboard.itemList.remove(item);
                          });
                        }
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: adminPink,
        foregroundColor: Colors.white,
        onPressed: _addItem,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _addItem() async {
    final item = await Navigator.push<ItemModel>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddItemScreen(),
      ),
    );

    if (!mounted || item == null) return;

    setState(() {
      dashboard.itemList.add(item);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Barang berhasil ditambahkan!'),
      ),
    );
  }

  // ==================== PENGGUNA ====================

  Widget _buildUsers() {
    // Perlindungan tambahan: admin biasa tidak dapat membuka
    // halaman persetujuan ini.
    if (!isSuperAdmin) {
      return const Center(
        child: Text('Kamu tidak memiliki akses ke halaman ini.'),
      );
    }

    final users = UserStore.users
        .where(
          (user) => user.role == 'user' || user.role == 'admin',
        )
        .toList();

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Padding(
          padding: EdgeInsets.all(8),
          child: Text(
            'Daftar Pengguna',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (users.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Belum ada akun pengguna.'),
          ),
        ...users.map(
          (user) => Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Icon(
                  user.role == 'admin'
                      ? Icons.admin_panel_settings
                      : Icons.person,
                ),
              ),
              title: Text(
                '${user.name} (${user.role == 'admin' ? 'Admin' : 'User'})',
              ),
              subtitle: Text(
                'Username: ${user.username}\n'
                'Status: ${user.approved ? "Disetujui" : "Menunggu persetujuan"}',
              ),
              isThreeLine: true,
              trailing: user.approved
                  ? const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Setujui akun',
                          icon: const Icon(
                            Icons.check_circle_outline,
                            color: adminPink,
                          ),
                          onPressed: () async {
                            try {
                              await UserStore.setApproval(
                                user.username,
                                true,
                              );

                              if (!mounted) return;

                              setState(() {});

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Akun ${user.name} berhasil disetujui.',
                                  ),
                                ),
                              );
                            } catch (e) {
                              if (!mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Gagal menyetujui akun: $e',
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                        IconButton(
                          tooltip: 'Tolak akun',
                          icon: const Icon(
                            Icons.cancel_outlined,
                            color: Colors.red,
                          ),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                title: const Text('Tolak Pendaftaran'),
                                content: Text(
                                  'Yakin ingin menolak pendaftaran ${user.name}?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(dialogContext, false);
                                    },
                                    child: const Text('Batal'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(dialogContext, true);
                                    },
                                    child: const Text('Tolak'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm != true || !mounted) return;

                            try {
                              await UserStore.rejectUser(user.username);

                              if (!mounted) return;

                              setState(() {});

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Pendaftaran ${user.name} ditolak.',
                                  ),
                                ),
                              );
                            } catch (e) {
                              if (!mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Gagal menolak akun: $e',
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  // ==================== PROFIL ADMIN ====================

  Widget _buildProfile() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(child: _buildLogo(height: 90)),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'BIODATA ADMIN',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 24),
        _profileRow('Nama', widget.user.name, Icons.person),
        _profileRow(
          'Username',
          widget.user.username,
          Icons.account_circle,
        ),
        _profileRow(
          'Role',
          isSuperAdmin ? 'Admin Super' : 'Administrator',
          Icons.verified_user,
        ),
        _profileRow(
          'Password',
          '••••••••',
          Icons.lock,
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(14),
          ),
          onPressed: _logout,
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
        ),
      ],
    );
  }

  Widget _profileRow(
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: adminPink),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }

  // ==================== LOGOUT ====================

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Yakin ingin keluar dari akun admin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
        (route) => false,
      );
    }
  }
}