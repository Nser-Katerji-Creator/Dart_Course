import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import '../blocs/auth/auth_event.dart';
import '../services/theme_service.dart';
import '../services/notification_service.dart';
import '../widgets/settings_section.dart';
import '../widgets/change_email_dialog.dart';
import '../widgets/change_password_dialog.dart';
import 'payment_methods_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotificationsEnabled = true;
  bool _pushNotificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  void _loadNotificationSettings() async {
    // Load current notification settings from preferences or service
    // This is a placeholder - you'd implement actual persistence
    setState(() {
      _notificationsEnabled = true; // Default value
      _emailNotificationsEnabled = true;
      _pushNotificationsEnabled = true;
    });
  }

  void _saveNotificationSettings() async {
    // Save notification settings to preferences or service
    // This would integrate with your notification service
    final notificationService = NotificationService();
    
    if (_notificationsEnabled) {
      await notificationService.initialize();
    } else {
      // Disable notifications
      await notificationService.cancelAllNotifications();
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification settings saved'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showChangeEmailDialog() {
    showDialog(
      context: context,
      builder: (context) => const ChangeEmailDialog(),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => const ChangePasswordDialog(),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Implement account deletion
              Navigator.pop(context);
              _deleteAccount();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteAccount() {
    // Implement account deletion logic
    // This would integrate with your auth service
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account deletion feature coming soon'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          String userEmail = 'user@example.com'; // Default
          if (authState is AuthSuccess) {
            userEmail = authState.user.email ?? 'No email';
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Profile Section
                SettingsSection(
                  title: 'Profile',
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Icon(
                          Icons.person,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      title: Text(userEmail),
                      subtitle: const Text('Tap to view profile'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Navigate to profile screen
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Profile screen coming soon')),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Notifications Section
                SettingsSection(
                  title: 'Notifications',
                  children: [
                    SwitchListTile(
                      title: const Text('Enable Notifications'),
                      subtitle: const Text('Receive parking reminders and updates'),
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() {
                          _notificationsEnabled = value;
                          if (!value) {
                            _emailNotificationsEnabled = false;
                            _pushNotificationsEnabled = false;
                          }
                        });
                        _saveNotificationSettings();
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Push Notifications'),
                      subtitle: const Text('Instant alerts on your device'),
                      value: _pushNotificationsEnabled,
                      onChanged: _notificationsEnabled ? (value) {
                        setState(() {
                          _pushNotificationsEnabled = value;
                        });
                        _saveNotificationSettings();
                      } : null,
                    ),
                    SwitchListTile(
                      title: const Text('Email Notifications'),
                      subtitle: const Text('Receive updates via email'),
                      value: _emailNotificationsEnabled,
                      onChanged: _notificationsEnabled ? (value) {
                        setState(() {
                          _emailNotificationsEnabled = value;
                        });
                        _saveNotificationSettings();
                      } : null,
                    ),
                  ],
                ),

                const SizedBox(height: 24),                // Account Management Section
                SettingsSection(
                  title: 'Account Management',
                  children: [
                    ListTile(
                      leading: const Icon(Icons.email_outlined),
                      title: const Text('Change Email Address'),
                      subtitle: Text(userEmail),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: _showChangeEmailDialog,
                    ),
                    ListTile(
                      leading: const Icon(Icons.lock_outline),
                      title: const Text('Change Password'),
                      subtitle: const Text('Update your password'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: _showChangePasswordDialog,
                    ),
                    ListTile(
                      leading: const Icon(Icons.payment),
                      title: const Text('Payment Methods'),
                      subtitle: const Text('Manage cards and payment options'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PaymentMethodsScreen()),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.security),
                      title: const Text('Two-Factor Authentication'),
                      subtitle: const Text('Add extra security to your account'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('2FA feature coming soon')),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // App Preferences Section
                SettingsSection(
                  title: 'App Preferences',
                  children: [
                    SwitchListTile(
                      title: const Text('Dark Mode'),
                      subtitle: const Text('Use dark theme'),
                      value: themeService.isDarkMode,
                      onChanged: (value) {
                        themeService.toggleTheme();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.language),
                      title: const Text('Language'),
                      subtitle: const Text('English'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Language selection coming soon')),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.location_on_outlined),
                      title: const Text('Location Services'),
                      subtitle: const Text('Manage location permissions'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Location settings coming soon')),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Support Section
                SettingsSection(
                  title: 'Support',
                  children: [
                    ListTile(
                      leading: const Icon(Icons.help_outline),
                      title: const Text('Help & FAQ'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Help section coming soon')),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.feedback_outlined),
                      title: const Text('Send Feedback'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Feedback form coming soon')),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('About ParkMe'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        _showAboutDialog();
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Danger Zone
                SettingsSection(
                  title: 'Danger Zone',
                  children: [
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.orange),
                      title: const Text('Sign Out', style: TextStyle(color: Colors.orange)),
                      onTap: () {
                        _showSignOutDialog();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.delete_forever, color: Colors.red),
                      title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
                      onTap: _showDeleteAccountDialog,
                    ),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'ParkMe',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(
        Icons.local_parking,
        size: 48,
        color: Theme.of(context).primaryColor,
      ),
      children: [
        const Text('ParkMe is a smart parking management app that helps you find, book, and manage parking spaces efficiently.'),
        const SizedBox(height: 16),
        const Text('© 2025 ParkMe Team. All rights reserved.'),
      ],
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(LogoutRequested());
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
