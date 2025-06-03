import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/theme_controller.dart';
import '../controllers/auth_controller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _checkAndRequestPermissions() async {
    final notificationStatus = await Permission.notification.status;
    final alarmStatus = await Permission.scheduleExactAlarm.status;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Permission Status',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildPermissionTile(
              'Notifications',
              notificationStatus.isGranted,
              () async => await openAppSettings(),
            ),
            const SizedBox(height: 16),
            _buildPermissionTile(
              'Exact Alarms',
              alarmStatus.isGranted,
              () async => await openAppSettings(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionTile(String title, bool isGranted, VoidCallback onTap) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Get.theme.colorScheme.primary.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            isGranted ? Icons.check_circle : Icons.error_outline,
            color: isGranted ? Colors.green : Colors.orange,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (!isGranted)
            TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Enable'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final authController = Get.find<AuthController>();
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),
                    Text(
                      'Settings',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      // User Profile Section
                      if (authController.isSignedIn) ...[
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary.withOpacity(0.1),
                                theme.colorScheme.secondary.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      theme.colorScheme.primary,
                                      theme.colorScheme.secondary,
                                    ],
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.white,
                                  backgroundImage: authController.firebaseService.currentUser?.photoURL != null
                                      ? NetworkImage(authController.firebaseService.currentUser!.photoURL!)
                                      : null,
                                  child: authController.firebaseService.currentUser?.photoURL == null
                                      ? Icon(Icons.person, size: 50, color: theme.colorScheme.primary)
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                authController.firebaseService.currentUser?.displayName ?? 'User',
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                authController.firebaseService.currentUser?.email ?? '',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 20),
                              OutlinedButton.icon(
                                onPressed: () => authController.signOut(),
                                icon: const Icon(Icons.logout),
                                label: const Text('Sign Out'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Appearance Section
                      _buildSettingsSection(
                        theme,
                        'Appearance',
                        [
                          Obx(() => _buildSettingsTile(
                            theme,
                            'Dark Mode',
                            'Customize app theme',
                            Icons.dark_mode,
                            trailing: Switch(
                              value: themeController.isDarkMode,
                              onChanged: (_) => themeController.toggleTheme(),
                            ),
                          )),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Notifications Section
                      _buildSettingsSection(
                        theme,
                        'Notifications',
                        [
                          _buildSettingsTile(
                            theme,
                            'Notification Permissions',
                            'Manage notification and alarm permissions',
                            Icons.notifications,
                            onTap: _checkAndRequestPermissions,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // About Section
                      _buildSettingsSection(
                        theme,
                        'About',
                        [
                          _buildSettingsTile(
                            theme,
                            'Version',
                            '1.0.0',
                            Icons.info,
                          ),
                          _buildSettingsTile(
                            theme,
                            'Terms of Service',
                            'Read our terms and conditions',
                            Icons.description,
                            onTap: () {
                              // TODO: Implement terms of service
                            },
                          ),
                          _buildSettingsTile(
                            theme,
                            'Privacy Policy',
                            'Read our privacy policy',
                            Icons.privacy_tip,
                            onTap: () {
                              // TODO: Implement privacy policy
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection(ThemeData theme, String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    ThemeData theme,
    String title,
    String subtitle,
    IconData icon, {
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 8,
      ),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: theme.colorScheme.primary,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: theme.textTheme.bodySmall?.color,
        ),
      ),
      trailing: trailing ?? (onTap != null
          ? Icon(
              Icons.chevron_right,
              color: theme.colorScheme.primary,
            )
          : null),
      onTap: onTap,
    );
  }
} 