import 'package:material_ui/material_ui.dart';

import '../../data/app_database.dart';
import '../../data/repositories/subscriber_repository.dart';
import 'view_models/edit_subscriber_form_view_model.dart';
import 'widgets/subscriber_details_section.dart';

class EditSubscriberForm extends StatefulWidget {
  const EditSubscriberForm({
    super.key,
    required this.repository,
    required this.subscriber,
  });

  final SubscriberRepository repository;
  final Subscriber subscriber;

  @override
  State<EditSubscriberForm> createState() => _EditSubscriberFormState();
}

class _EditSubscriberFormState extends State<EditSubscriberForm> {
  final _formKey = GlobalKey<FormState>();
  late final EditSubscriberFormViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = EditSubscriberFormViewModel(
      widget.repository,
      widget.subscriber,
    );
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
      builder: (context, child) =>
          PopScope(canPop: !_viewModel.isSaving, child: _buildDialog(context)),
    );
  }

  Widget _buildDialog(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width - 48;
    return AlertDialog(
      title: const Text('Edit subscriber'),
      content: SizedBox(
        width: width < 640 ? width : 640,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SubscriberDetailsSection(viewModel: _viewModel),
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
              : const Icon(Icons.save),
          label: const Text('Save'),
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
