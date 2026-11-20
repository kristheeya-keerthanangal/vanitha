import 'package:material_ui/material_ui.dart';
import 'add_subscriber_button.dart';

class SubscribersToolbar extends StatelessWidget {
  const SubscribersToolbar({
    super.key,
    required this.search,
    required this.onSearch,
  });
  final String search;
  final ValueChanged<String> onSearch;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      LayoutBuilder(
        builder: (context, constraints) {
          final heading = Text(
            'Subscribers',
            style: Theme.of(context).textTheme.headlineMedium,
          );
          const addButton = AddSubscriberButton();

          if (constraints.maxWidth < 560) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [heading, const SizedBox(height: 12), addButton],
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [heading, addButton],
          );
        },
      ),
      const SizedBox(height: 16),
      TextFormField(
        initialValue: search,
        onChanged: onSearch,
        decoration: InputDecoration(
          labelText: 'Search subscribers',
          hint: Text('Enter Name, email or phone'),
          prefixIcon: Icon(Icons.search),
        ),
      ),
    ],
  );
}
