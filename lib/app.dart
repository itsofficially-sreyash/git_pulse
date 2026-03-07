import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/onboarding/presentation/providers/onboarding_provider.dart';
import 'features/onboarding/presentation/providers/theme_provider.dart';
import 'features/onboarding/presentation/screens/onboarding_shell.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/activity/presentation/screens/activity_screen.dart';
import 'features/widget/widget_provider.dart';
import 'shared/theme/app_theme.dart';
import 'shared/theme/app_colors.dart';

class GitPulseApp extends ConsumerWidget {
  const GitPulseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeAsync = ref.watch(themeProvider);
    final themeMode = themeAsync.value ?? ThemeMode.dark;

    return MaterialApp(
      title: 'Git Pulse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const _RootRouter(),
    );
  }
}

class _RootRouter extends ConsumerWidget {
  const _RootRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final tour = ref.watch(tourProvider);

    if (auth.isLoading) return const _SplashScreen();

    final isAuthed = auth.value != null;

    if (!isAuthed) return const OnboardingShell();

    return const MainShell();
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.hub, size: 48, color: AppColors.blue),
            SizedBox(height: 12),
            Text(
              'Git Pulse',
              style: TextStyle(
                color: AppColors.darkTextPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _selectedIndex = 0;

  static const _screens = [DashboardScreen(), ActivityScreen()];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(syncWidgetProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: borderColor)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
          backgroundColor: surfaceColor,
          selectedItemColor: AppColors.blue,
          unselectedItemColor: isDark
              ? AppColors.darkTextMuted
              : AppColors.lightTextMuted,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Activity',
            ),
          ],
        ),
      ),
    );
  }
}
