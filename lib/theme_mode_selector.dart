import 'package:flutter/material.dart';

class ThemeModeSelector extends StatelessWidget {
  final ThemeMode currentMode;
  final ValueChanged<ThemeMode?> onChanged;

  const ThemeModeSelector({
    super.key,
    required this.currentMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<ThemeMode?>(
      value: currentMode,
      onChanged: onChanged,
      items: const [
        DropdownMenuItem(value: ThemeMode.system, child: Text("Automático")),
        DropdownMenuItem(value: ThemeMode.light, child: Text("Claro")),
        DropdownMenuItem(value: ThemeMode.dark, child: Text("Oscuro")),
      ],
    );
  }
}
