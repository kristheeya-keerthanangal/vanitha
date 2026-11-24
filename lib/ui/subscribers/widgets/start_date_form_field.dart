import 'package:material_ui/material_ui.dart';

class MonthPickerDialog extends StatefulWidget {
  const MonthPickerDialog({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  @override
  State<MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<MonthPickerDialog> {
  late int _selectedYear;

  static const _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate.year;
  }

  bool _isMonthEnabled(int month) {
    final monthDate = DateTime(_selectedYear, month);
    final minDate = DateTime(widget.firstDate.year, widget.firstDate.month);
    final maxDate = DateTime(widget.lastDate.year, widget.lastDate.month);
    return !monthDate.isBefore(minDate) && !monthDate.isAfter(maxDate);
  }

  @override
  Widget build(BuildContext context) {
    final minYear = widget.firstDate.year;
    final maxYear = widget.lastDate.year;

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _selectedYear > minYear
                ? () => setState(() => _selectedYear--)
                : null,
          ),
          Text('$_selectedYear', style: Theme.of(context).textTheme.titleLarge),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _selectedYear < maxYear
                ? () => setState(() => _selectedYear++)
                : null,
          ),
        ],
      ),
      content: SizedBox(
        width: 280,
        height: 200,
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.8,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: 12,
          itemBuilder: (context, index) {
            final month = index + 1;
            final isEnabled = _isMonthEnabled(month);
            final isSelected = _selectedYear == widget.initialDate.year &&
                month == widget.initialDate.month;

            return isSelected
                ? FilledButton(
                    onPressed: isEnabled
                        ? () => Navigator.of(context).pop(
                              DateTime(_selectedYear, month),
                            )
                        : null,
                    child: Text(_monthNames[index]),
                  )
                : OutlinedButton(
                    onPressed: isEnabled
                        ? () => Navigator.of(context).pop(
                              DateTime(_selectedYear, month),
                            )
                        : null,
                    child: Text(_monthNames[index]),
                  );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

class StartMonthFormField extends StatelessWidget {
  const StartMonthFormField({
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
    final monthLabel = value == null
        ? ''
        : '${value!.year.toString().padLeft(4, '0')}-'
            '${value!.month.toString().padLeft(2, '0')}';
    return TextFormField(
      key: ValueKey(monthLabel),
      initialValue: monthLabel,
      readOnly: true,
      decoration: const InputDecoration(
        labelText: 'Start month',
        suffixIcon: Icon(Icons.calendar_today_outlined),
      ),
      onTap: locked
          ? null
          : () async {
              final selected = await showDialog<DateTime>(
                context: context,
                builder: (context) => MonthPickerDialog(
                  initialDate: value ?? DateTime.now(),
                  firstDate: firstDate ?? DateTime(2000),
                  lastDate: lastDate ?? DateTime(2100),
                ),
              );
              if (selected != null) onChanged(selected);
            },
      validator: validator,
    );
  }
}

typedef StartDateFormField = StartMonthFormField;
