import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_pdf_tools/presentation/view/pages/history.dart';
import 'package:smart_pdf_tools/presentation/view/pages/home.dart';
import 'package:smart_pdf_tools/presentation/view/pages/settings.dart';
import 'package:smart_pdf_tools/presentation/viewmodels/document_provider.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int _index = 0;
  final _pages = [HomeScreen(), HistoryScreen(), SettingsScreen()];

  @override
  void initState() {
    super.initState();
    context.read<DocumentProvider>().loadDocuments();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      body: SafeArea(child: _pages[_index]),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Theme.of(
          context,
        ).bottomNavigationBarTheme.backgroundColor,
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        indicatorColor: Theme.of(
          context,
        ).bottomNavigationBarTheme.backgroundColor,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_filled),
            selectedIcon: Icon(Icons.home_filled, color: primaryColor),
            label: 'Home',
          ),

          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history, color: primaryColor),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings, color: primaryColor),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
