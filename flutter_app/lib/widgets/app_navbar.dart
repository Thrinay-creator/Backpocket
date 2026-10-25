import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class AppNavbar extends StatelessWidget implements PreferredSizeWidget {
  final String currentRoute;

  const AppNavbar({
    super.key,
    required this.currentRoute,
  });

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isDark = themeProvider.isDarkMode;

    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          // Monogram / Logo
          InkWell(
            onTap: () {
              if (currentRoute != '/') {
                Navigator.pushNamed(context, '/');
              }
            },
            borderRadius: BorderRadius.circular(10),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withAlpha(50),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.help_center_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Backpocket',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'CAMPUS LOST & FOUND',
                      style: TextStyle(
                        fontSize: 9,
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.w700,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Search button
        TextButton.icon(
          onPressed: () {
            if (currentRoute != '/search') {
              Navigator.pushNamed(context, '/search');
            }
          },
          icon: const Icon(Icons.search_rounded, size: 18),
          label: const Text('Search'),
          style: TextButton.styleFrom(
            foregroundColor: currentRoute == '/search'
                ? Theme.of(context).colorScheme.primary
                : null,
          ),
        ),
        const SizedBox(width: 4),

        // Staff portal button
        TextButton.icon(
          onPressed: () {
            if (authProvider.isStaff) {
              if (currentRoute != '/staff/dashboard') {
                Navigator.pushNamed(context, '/staff/dashboard');
              }
            } else {
              if (currentRoute != '/staff/login') {
                Navigator.pushNamed(context, '/staff/login');
              }
            }
          },
          icon: Icon(
            authProvider.isStaff ? Icons.dashboard_rounded : Icons.admin_panel_settings_rounded,
            size: 18,
          ),
          label: Text(authProvider.isStaff ? 'Dashboard' : 'Staff'),
          style: TextButton.styleFrom(
            foregroundColor: currentRoute.startsWith('/staff')
                ? Theme.of(context).colorScheme.primary
                : null,
          ),
        ),
        const SizedBox(width: 4),

        // Theme Toggle button
        IconButton(
          tooltip: isDark ? 'Switch to Light Theme' : 'Switch to Dark Theme',
          onPressed: () {
            themeProvider.toggleTheme();
          },
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF475569),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
