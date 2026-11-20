import 'package:material_ui/material_ui.dart';

class DetailsCard extends StatelessWidget {
  const DetailsCard({
    super.key,
    required this.title,
    required this.fields,
    this.trailing,
  });
  final String title;
  final Widget? trailing;
  final Map<String, String?> fields;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 12),
          for (final entry in fields.entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Wrap(
                spacing: 12,
                children: [
                  Text(
                    entry.key,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  Text(entry.value?.isNotEmpty == true ? entry.value! : '—'),
                ],
              ),
            ),
        ],
      ),
    ),
  );
}
