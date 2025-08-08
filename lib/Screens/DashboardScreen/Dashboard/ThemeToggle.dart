import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickcash/utils/themeProvider.dart';

class ThemeToggleButton extends StatelessWidget {
  final bool isDark;

  const ThemeToggleButton({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        Provider.of<ThemeProvider>(context, listen: false)
            .toggleTheme(!isDark);
      },
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) => RotationTransition(
          turns: child.key == const ValueKey('moon')
              ? Tween<double>(begin: 1, end: 0.75).animate(animation)
              : Tween<double>(begin: 0.75, end: 1).animate(animation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        ),
        child: Icon(
          isDark ? Icons.wb_sunny : Icons.wb_sunny,
          key: ValueKey(isDark ? 'moon' : 'sun'),
          color: isDark ? Colors.black : Colors.white,
          size: 28,
        ),
      ),
      tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
    );
  }
}
