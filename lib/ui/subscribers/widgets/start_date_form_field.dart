import 'package:flutter/material.dart';

class StartDateFormField extends StatelessWidget {
  const StartDateFormField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.validator,
    this.firstDate,
    this.lastDate,
    this.locked = false,
  });

  final DateTime? value;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool locked;
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
      onTap: locked
          ? null
          : () async {
              final selected = await showDatePicker(
                context: context,
                firstDate: firstDate ?? DateTime(2000),
                lastDate: lastDate ?? DateTime(2100),
                initialDate: value ?? DateTime.now(),
              );
              if (selected != null) onChanged(selected);
            },
      validator: validator,
    );
  }
}
