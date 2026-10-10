import 'package:flutter/material.dart';

class AppTextFormField extends StatelessWidget {
  const AppTextFormField({
    super.key,
    required this.label,
    required this.onChanged,
    this.initialValue = '',
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
  });

  final String label;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(labelText: label),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      onChanged: onChanged,
      textInputAction: maxLines == 1
          ? TextInputAction.next
          : TextInputAction.newline,
    );
  }
}

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

class StartDateFormField extends StatelessWidget {
  const StartDateFormField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.validator,
  });

  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    final dateLabel = value == null
        ? ''
        : '${value!.year.toString().padLeft(4, '0')}-'
              '${value!.month.toString().padLeft(2, '0')}-'
              '${value!.day.toString().padLeft(2, '0')}';
    return TextFormField(
      key: ValueKey(dateLabel),
      initialValue: dateLabel,
      readOnly: true,
      decoration: const InputDecoration(
        labelText: 'Start date',
        suffixIcon: Icon(Icons.calendar_today_outlined),
      ),
      onTap: () async {
        final selected = await showDatePicker(
          context: context,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          initialDate: value ?? DateTime.now(),
        );
        if (selected != null) onChanged(selected);
      },
      validator: validator,
    );
  }
}
