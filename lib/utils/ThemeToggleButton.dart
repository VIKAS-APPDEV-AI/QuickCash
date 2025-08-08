import 'package:flutter/material.dart';

class ThemeToggleButton extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggle;

  const ThemeToggleButton({
    super.key,
    required this.isDark,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onToggle,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) => RotationTransition(
          turns: child.key == const ValueKey('sun')
              ? Tween(begin: 1.0, end: 0.75).animate(animation)
              : Tween(begin: 0.75, end: 1.0).animate(animation),
          child: child,
        ),
        child: Icon(
          isDark ? Icons.nightlight_round : Icons.wb_sunny,
          key: ValueKey(isDark ? 'moon' : 'sun'),
          color: isDark ? Colors.amber[200] : Colors.orange,
        ),
      ),
      tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
    );
  }
}
