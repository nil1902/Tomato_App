import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/admin_service.dart';

/// Users Tab - Manage all users
class UsersTab extends StatefulWidget {
  const UsersTab({super.key});

  @override
  State<UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> {
  List<dynamic> _users = [];
  bool _loading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _loading = true);
    final authService = context.read<AuthService>();
    if (authService.accessToken == null) return;

    final adminService = AdminService(authService.accessToken!);
    final users = await adminService.getAllUsers();
    
    setState(() {
      _users = users;
      _loading = false;
    });
  }

  List<dynamic> get _filteredUsers {
    if (_searchQuery.isEmpty) return _users;
    return _users.where((user) {
      final name = user['full_name']?.toString().toLowerCase() ?? '';
      final email = user['email']?.toString().toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || email.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search Bar
          Row(
            children: [
              Expanded(
                flex: isDesktop ? 1 : 2,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
              ),
              if (isDesktop) const Spacer(flex: 2),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadUsers,
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Users List / Table Data
          Expanded(
            child: _filteredUsers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty ? 'No users found' : 'No matching users',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: isDesktop 
                        ? ListView(
                            children: [
                              PaginatedDataTable(
                                header: const Text('Users'),
                                rowsPerPage: _filteredUsers.length > 10 ? 10 : (_filteredUsers.isEmpty ? 1 : _filteredUsers.length),
                                source: _UserDataTableSource(
                                  _filteredUsers,
                                  _showUserOptions,
                                ),
                                columns: const [
                                  DataColumn(label: Text('Name')),
                                  DataColumn(label: Text('Email')),
                                  DataColumn(label: Text('Role')),
                                  DataColumn(label: Text('Joined')),
                                  DataColumn(label: Text('Actions')),
                                ],
                              )
                            ],
                          )
                        : RefreshIndicator(
                            onRefresh: _loadUsers,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              itemCount: _filteredUsers.length,
                              itemBuilder: (context, index) {
                                final user = _filteredUsers[index];
                                return _buildUserCard(user);
                              },
                            ),
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final name = user['full_name'] ?? 'Unknown User';
    final email = user['email'] ?? 'No email';
    final role = user['role'] ?? 'user';
    final createdAt = user['created_at'] ?? '';
    final isAdmin = role == 'admin';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showUserOptions(user),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 30,
                backgroundColor: isAdmin ? Colors.orange[100] : Colors.blue[100],
                child: Icon(
                  isAdmin ? Icons.admin_panel_settings : Icons.person,
                  color: isAdmin ? Colors.orange[700] : Colors.blue[700],
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isAdmin)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'ADMIN',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[700],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Joined: ${createdAt.split('T')[0]}',
                      style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              
              // Actions
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showUserOptions(user),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUserOptions(Map<String, dynamic> user) {
    final isAdmin = user['role'] == 'admin';
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                isAdmin ? Icons.person : Icons.admin_panel_settings,
                color: Colors.blue,
              ),
              title: Text(isAdmin ? 'Remove Admin Role' : 'Make Admin'),
              onTap: () {
                Navigator.pop(context);
                _toggleAdminRole(user);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete User'),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(user);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleAdminRole(Map<String, dynamic> user) async {
    final isAdmin = user['role'] == 'admin';
    final newRole = isAdmin ? 'user' : 'admin';
    
    final authService = context.read<AuthService>();
    final adminService = AdminService(authService.accessToken!);
    final success = await adminService.updateUserRole(user['user_id'], newRole);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User role updated to $newRole')),
      );
      _loadUsers();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update user role')),
      );
    }
  }

  void _confirmDelete(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user['full_name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final authService = context.read<AuthService>();
              final adminService = AdminService(authService.accessToken!);
              final success = await adminService.deleteUser(user['user_id']);
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User deleted successfully!')),
                );
                _loadUsers();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to delete user')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _UserDataTableSource extends DataTableSource {
  final List<dynamic> _users;
  final Function(Map<String, dynamic>) _onRowTap;

  _UserDataTableSource(this._users, this._onRowTap);

  @override
  DataRow? getRow(int index) {
    if (index >= _users.length) return null;
    final user = _users[index] as Map<String, dynamic>;
    final isAdmin = user['role'] == 'admin';
    final name = user['full_name'] ?? 'Unknown User';
    final email = user['email'] ?? 'No email';
    final role = user['role'] ?? 'user';
    final joined = user['created_at']?.split('T')[0] ?? '';

    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: isAdmin ? Colors.orange[100] : Colors.blue[100],
                child: Icon(
                  isAdmin ? Icons.admin_panel_settings : Icons.person,
                  color: isAdmin ? Colors.orange[700] : Colors.blue[700],
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        DataCell(Text(email)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isAdmin ? Colors.orange[100] : Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              role.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isAdmin ? Colors.orange[700] : Colors.blue[700],
              ),
            ),
          ),
        ),
        DataCell(Text(joined)),
        DataCell(
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _onRowTap(user),
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _users.length;

  @override
  int get selectedRowCount => 0;
}
