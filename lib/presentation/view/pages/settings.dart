// import 'package:flutter/material.dart';
// import 'package:lucide_icons/lucide_icons.dart';

// class SettingsScreen extends StatelessWidget {
//   const SettingsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Settings'), centerTitle: true),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           _sectionTitle('General'),
//           _settingsTile(
//             icon: LucideIcons.moon,
//             title: 'Dark Mode',
//             subtitle: 'Automatically adjust theme',
//             trailing: Switch(value: false, onChanged: (_) {}),
//           ),
//           _settingsTile(
//             icon: LucideIcons.languages,
//             title: 'Language',
//             subtitle: 'English',
//             trailing: const Icon(Icons.chevron_right),
//           ),

//           const SizedBox(height: 24),
//           _sectionTitle('PDF Preferences'),
//           _settingsTile(
//             icon: LucideIcons.fileMinus,
//             title: 'Compression Level',
//             subtitle: 'Medium (Recommended)',
//             trailing: const Icon(Icons.chevron_right),
//           ),
//           _settingsTile(
//             icon: LucideIcons.fileLock,
//             title: 'Password Protect PDFs',
//             subtitle: 'Enable encryption by default',
//             trailing: Switch(value: true, onChanged: (_) {}),
//           ),

//           const SizedBox(height: 24),
//           _sectionTitle('Storage'),
//           _settingsTile(
//             icon: LucideIcons.folder,
//             title: 'Save Location',
//             subtitle: 'Downloads / Smart PDF Tools',
//             trailing: const Icon(Icons.chevron_right),
//           ),
//           _settingsTile(
//             icon: LucideIcons.trash2,
//             title: 'Auto Delete Temporary Files',
//             subtitle: 'After 24 hours',
//             trailing: Switch(value: true, onChanged: (_) {}),
//           ),

//           const SizedBox(height: 24),
//           _sectionTitle('Security & Privacy'),
//           _settingsTile(
//             icon: LucideIcons.shield,
//             title: 'Local Processing',
//             subtitle: 'Files never leave your device',
//           ),
//           _settingsTile(
//             icon: LucideIcons.lock,
//             title: 'App Lock',
//             subtitle: 'Biometric / PIN protection',
//             trailing: Switch(value: false, onChanged: (_) {}),
//           ),

//           const SizedBox(height: 24),
//           _sectionTitle('About'),
//           _settingsTile(
//             icon: LucideIcons.info,
//             title: 'Version',
//             subtitle: 'v1.0.0',
//           ),
//           _settingsTile(
//             icon: LucideIcons.helpCircle,
//             title: 'Help & Support',
//             trailing: const Icon(Icons.chevron_right),
//           ),
//           _settingsTile(
//             icon: LucideIcons.fileText,
//             title: 'Privacy Policy',
//             trailing: const Icon(Icons.chevron_right),
//           ),

//           const SizedBox(height: 32),
//         ],
//       ),
//     );
//   }

//   Widget _sectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Text(
//         title.toUpperCase(),
//         style: const TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.w600,
//           letterSpacing: 1.1,
//           color: Colors.grey,
//         ),
//       ),
//     );
//   }

//   Widget _settingsTile({
//     required IconData icon,
//     required String title,
//     String? subtitle,
//     Widget? trailing,
//   }) {
//     return Card(
//       elevation: 0.5,
//       margin: const EdgeInsets.symmetric(vertical: 6),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: ListTile(
//         leading: Icon(icon, size: 20),
//         title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
//         subtitle: subtitle != null ? Text(subtitle) : null,
//         trailing: trailing,
//         onTap: trailing == null ? null : () {},
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _settingsTile(
            icon: LucideIcons.moon,
            title: 'Dark Mode',
            subtitle: 'Dark mode coming soon',
            trailing: Switch(value: false, onChanged: (_) {}),
          ),

          _settingsTile(
            icon: LucideIcons.languages,
            title: 'Language',
            subtitle: 'English',
            trailing: const Icon(Icons.chevron_right),
          ),

          const Divider(height: 32),

          _settingsTile(
            icon: LucideIcons.folder,
            title: 'Save Location',
            subtitle: 'Device storage',
            trailing: const Icon(Icons.chevron_right),
          ),

          _settingsTile(
            icon: LucideIcons.shield,
            title: 'Privacy',
            subtitle: 'Files processed locally',
          ),

          const Divider(height: 32),

          _settingsTile(
            icon: LucideIcons.info,
            title: 'App Version',
            subtitle: 'v1.0.0',
          ),

          _settingsTile(
            icon: LucideIcons.helpCircle,
            title: 'Help & Support',
            trailing: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: Icon(icon, size: 20),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing,
      onTap: trailing is Icon ? () {} : null,
    );
  }
}
