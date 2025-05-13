import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  const SettingsPage({
    super.key,
    required this.currentMode,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración de Tema')),
      body: Column(
        children: [
          RadioListTile<ThemeMode>(
            title: const Text('Automático'),
            value: ThemeMode.system,
            groupValue: currentMode,
            onChanged: (ThemeMode? mode) {
              if (mode != null) onThemeChanged(mode);
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Claro'),
            value: ThemeMode.light,
            groupValue: currentMode,
            onChanged: (ThemeMode? mode) {
              if (mode != null) onThemeChanged(mode);
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Oscuro'),
            value: ThemeMode.dark,
            groupValue: currentMode,
            onChanged: (ThemeMode? mode) {
              if (mode != null) onThemeChanged(mode);
            },
          ),
        ],
      ),
    );
  }
}
