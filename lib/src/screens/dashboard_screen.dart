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
      case 'institute':
        body = _instituteView();
        break;
      case 'educator':
        body = _educatorView();
        break;
      case 'individualeducator':
        body = _individualEducatorView();
        break;
      case 'parent':
        body = _parentView();
        break;
      case 'student':
        body = _studentView();
        break;
      default:
        body = _userView();
    }

    return Scaffold(
      appBar: AppBar(title: Text('Dashboard - ${role[0].toUpperCase()}${role.substring(1)}')),
      body: Padding(padding: const EdgeInsets.all(16.0), child: body),
    );
  }

  Widget _adminView() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Admin Panel', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text('• Manage users'),
          Text('• View system metrics'),
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
          Text('• View your profile'),
          Text('• Browse content'),
        ],
      );

  String _normalizeRole(String r) {
    final key = r.trim().toLowerCase();
    switch (key) {
      case 'admin':
        return 'admin';
      case 'institute':
      case 'organisation':
      case 'organization':
        return 'institute';
      case 'educator':
        return 'educator';
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

}
