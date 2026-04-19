import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../config/app_theme.dart';
import '../../../core/auth/auth_service.dart';
import '../../auth/controller/auth_controller.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Farm profile')),
      body: Obx(() {
        final farm = auth.orgName.value;
        final name = auth.userFullName.value;
        final email = auth.userEmail.value;
        final role = auth.userRole.value;

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _FarmCard(farm: farm, role: role),
            const SizedBox(height: 16),
            _UserCard(name: name, email: email),
            const SizedBox(height: 32),
            _SignOutButton(),
          ],
        );
      }),
    );
  }
}

class _FarmCard extends StatelessWidget {
  final String? farm;
  final String? role;

  const _FarmCard({required this.farm, required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF102E2E), Color(0xFF185B37)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.home_work_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      farm ?? '—',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Your farm',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (role != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                role!.substring(0, 1).toUpperCase() + role!.substring(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final String? name;
  final String? email;

  const _UserCard({required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          if (name != null && name!.trim().isNotEmpty)
            _InfoRow(
              icon: Icons.person_outline,
              label: 'Name',
              value: name!.trim(),
            ),
          if (name != null && name!.trim().isNotEmpty)
            const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: email ?? '—',
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.textSecondary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}

class _SignOutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AuthController>();
    return Obx(
      () => OutlinedButton.icon(
        onPressed: ctrl.isSigningOut.value ? null : ctrl.signOut,
        icon: const Icon(Icons.logout, size: 18),
        label: Text(ctrl.isSigningOut.value ? 'Signing out…' : 'Sign out'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red.shade700,
          side: BorderSide(color: Colors.red.shade200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
