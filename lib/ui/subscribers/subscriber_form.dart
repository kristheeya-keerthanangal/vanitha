import 'package:material_ui/material_ui.dart';

import '../../data/repositories/subscriber_registration_repository.dart';
import 'widgets/subscriber_details_section.dart';
import 'widgets/subscription_details_section.dart';
import 'view_models/add_subscriber_form_view_model.dart';

class AddSubscriberForm extends StatefulWidget {
  const AddSubscriberForm({super.key, required this.repository});

  final SubscriberRegistrationRepository repository;

  @override
  State<AddSubscriberForm> createState() => _AddSubscriberFormState();
}

class _AddSubscriberFormState extends State<AddSubscriberForm> {
  final _formKey = GlobalKey<FormState>();
  late final AddSubscriberFormViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AddSubscriberFormViewModel(widget.repository);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, child) => _buildDialog(context),
    );
  }

  Widget _buildDialog(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width - 48;
    return AlertDialog(
      title: const Text('Add subscriber'),
      content: SizedBox(
        width: width < 640 ? width : 640,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SubscriberDetailsSection(viewModel: _viewModel),
                const SizedBox(height: 24),
                SubscriptionDetailsSection(viewModel: _viewModel),
                if (_viewModel.submitError != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _viewModel.submitError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _viewModel.isSaving
              ? null
              : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _viewModel.isSaving ? null : _save,
          icon: _viewModel.isSaving
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.person_add),
          label: const Text('Add subscriber'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!_formKey.currentState!.validate()) return;

    final saved = await _viewModel.save();
    if (saved && mounted) Navigator.of(context).pop(true);
  }
}
