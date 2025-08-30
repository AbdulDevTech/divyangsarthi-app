import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  final String role;
  const DashboardScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    Widget body;
    final key = _normalizeRole(role);
    switch (key) {
      case 'admin':
        body = _adminView();
        break;
      case 'Anstitute':
        body = _instituteView();
        break;
      case 'Educator':
        body = _educatorView();
        break;
      case 'Individualeducator':
        body = _individualEducatorView();
        break;
      case 'Parent':
        body = _parentView();
        break;
      case 'Student':
        body = _studentView();
        break;
      default:
        body = _userView();
    }

    return Scaffold(
      appBar: AppBar(title: Text('Dashboard - ${_displayRole(role)}')),
      body: Padding(padding: const EdgeInsets.all(16.0), child: Column(children: [
        // Top statistics row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _statCard('Active Users', '1,234', Icons.people, context),
            _statCard('Courses', '42', Icons.menu_book, context),
            _statCard('Revenue', '₹12.3k', Icons.attach_money, context),
            _statCard('Alerts', '3', Icons.notifications, context),
          ],
        ),
        const SizedBox(height: 18),
        // Role-specific content below
        Expanded(child: body),
      ])),
    );
  }

  String _displayRole(String r) {
    final trimmed = r.trim();
    if (trimmed.isEmpty) return '';
    final parts = trimmed.split(RegExp(r'[_\-\s]+'));
    final words = parts.map((p) {
      if (p.isEmpty) return '';
      return '${p[0].toUpperCase()}${p.substring(1)}';
    }).where((w) => w.isNotEmpty).toList();
    return words.join('');
  }

  Widget _adminView() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Admin Panel', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text('• Manage users'),
          Text('• View system metrics'),
        ],
      );

  Widget _instituteView() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Institute Dashboard', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text('• Manage courses'),
          Text('• Review enrollments'),
        ],
      );

  Widget _educatorView() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Educator Dashboard', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text('• Create content'),
          Text('• View student progress'),
        ],
      );

  Widget _individualEducatorView() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Individual Educator', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text('• Manage classes'),
          Text('• Track earnings'),
        ],
      );

  Widget _parentView() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Parent Dashboard', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text('• View child progress'),
          Text('• Contact educators'),
        ],
      );

  Widget _studentView() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Student Dashboard', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text('• View enrolled courses'),
          Text('• Continue learning'),
        ],
      );

  Widget _userView() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('User Dashboard', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text('• View your profile'),
          Text('• Browse content'),
        ],
      );

  String _normalizeRole(String r) {
    final key = r.trim().toLowerCase();
    switch (key) {
      case 'admin':
        return 'admin';
      case 'Institute':
      case 'organisation':
      case 'organization':
        return 'Institute';
      case 'educator':
        return 'Educator';
      case 'individualeducator':
      case 'individual_educator':
      case 'individual-educator':
      case 'individual educator':
        return 'individualeducator';
      case 'parent':
        return 'parent';
      case 'student':
        return 'student';
      default:
        // handle roles string that may itself be a role name
        if (key.contains('admin')) return 'admin';
        if (key.contains('educator')) return 'educator';
        if (key.contains('student')) return 'student';
        if (key.contains('parent')) return 'parent';
        return 'user';
    }
  }

  Widget _managerView() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Manager Panel', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text('• View team'),
          Text('• Approve requests'),
        ],
      );

  Widget _statCard(String title, String value, IconData icon, BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              CircleAvatar(backgroundColor: scheme.primaryContainer, child: Icon(icon, color: scheme.onPrimary)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  const SizedBox(height: 6),
                  Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: scheme.primary)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

}
