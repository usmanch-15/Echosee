// lib/presentation/widgets/custom/theme_toggle.dart
import 'package:flutter/material.dart';

class ThemeToggle extends StatefulWidget {
  final bool initialValue;
  final ValueChanged<bool>? onChanged;

  const ThemeToggle({
    Key? key,
    this.initialValue = false,
    this.onChanged,
  }) : super(key: key);

  @override
  _ThemeToggleState createState() => _ThemeToggleState();
}

class _ThemeToggleState extends State<ThemeToggle> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: _isDarkMode,
      onChanged: (value) {
        setState(() {
          _isDarkMode = value;
        });
        if (widget.onChanged != null) {
          widget.onChanged!(value);
        }
      },
      activeColor: Theme.of(context).primaryColor,
    );
  }
}