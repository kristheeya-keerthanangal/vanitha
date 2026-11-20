import 'package:material_ui/material_ui.dart';

class AppDropdownFormField extends StatelessWidget {
  const AppDropdownFormField({
    super.key,
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
    required this.validator,
  });

  final String label;
  final String? value;
  final Map<String, String> values;
  final ValueChanged<String?> onChanged;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final entry in values.entries)
          DropdownMenuItem(value: entry.key, child: Text(entry.value)),
      ],
      onChanged: onChanged,
      validator: validator,
    );
  }
}
