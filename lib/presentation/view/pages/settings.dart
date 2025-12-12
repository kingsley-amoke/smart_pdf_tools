import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_pdf_tools/presentation/viewmodels/document_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<DocumentProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 6),
          Text(
            'Settings',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          // ListTile(
          //   leading: Icon(Icons.palette),
          //   title: Text('Toggle Theme'),
          //   trailing: Switch(
          //     value: state.themeMode == ThemeMode.dark,
          //     onChanged: (_) => state.toggleTheme(),
          //   ),
          // ),
          ListTile(
            leading: Icon(Icons.storage),
            title: Text('Storage Location'),
            subtitle: Text('Local (default)'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.star_rate),
            title: Text('Rate App'),
            onTap: () {},
          ),
          Spacer(),
          Center(child: Text('v0.1 • Built with ♥')),
        ],
      ),
    );
  }
}
