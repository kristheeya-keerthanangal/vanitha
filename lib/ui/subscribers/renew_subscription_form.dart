import 'package:material_ui/material_ui.dart';

import '../../data/repositories/subscription_repository.dart';
import '../../data/subscription_renewal.dart';
import 'view_models/renew_subscription_view_model.dart';
import 'widgets/app_dropdown_form_field.dart';
import 'widgets/start_date_form_field.dart';

class RenewSubscriptionForm extends StatefulWidget {
  const RenewSubscriptionForm({
    super.key,
    required this.repository,
    required this.subscriberId,
    required this.rules,
  });

  final SubscriptionRepository repository;
  final int subscriberId;
  final SubscriptionRenewal rules;

  @override
  State<RenewSubscriptionForm> createState() => _RenewSubscriptionFormState();
}

class _RenewSubscriptionFormState extends State<RenewSubscriptionForm> {
  final _formKey = GlobalKey<FormState>();
  late final model = RenewSubscriptionViewModel(
    widget.repository,
    widget.subscriberId,
    widget.rules,
  );

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: model,
    builder: (context, _) => PopScope(
      canPop: !model.isSaving,
      child: AlertDialog(
        title: const Text('Renew subscription'),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: AbsorbPointer(
                absorbing: model.isSaving,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppDropdownFormField(
                      label: 'Edition',
                      value: model.edition,
                      values: const {'online': 'Online', 'offline': 'Offline'},
                      onChanged: (value) => model.edition = value!,
                      validator: (_) => null,
                    ),
                    const SizedBox(height: 12),
                    AppDropdownFormField(
                      label: 'Plan type',
                      value: model.planType,
                      values: const {
                        'annual': 'Annual',
                        'multi_year': 'Multi-year',
                        'lifetime': 'Lifetime',
                      },
                      onChanged: (value) => model.setPlan(value!),
                      validator: (_) => null,
                    ),
                    if (model.planType == 'multi_year') ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: model.duration,
                        decoration: const InputDecoration(
                          labelText: 'Duration (years)',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => model.duration = value,
                        validator: model.validateDuration,
                      ),
                    ],
                    const SizedBox(height: 12),
                    StartDateFormField(
                      value: model.startDate,
                      firstDate: model.rules.firstDate,
                      lastDate: model.rules.lastDate,
                      locked: model.rules.locked,
                      onChanged: (value) =>
                          setState(() => model.startDate = value),
                      validator: (_) => model.rules.allows(model.startDate)
                          ? null
                          : 'Invalid start date',
                    ),
                    if (model.rules.locked)
                      const Text(
                        'Starts the day after the current subscription expires.',
                      ),
                    if (model.error != null) Text(model.error!),
                  ],
                ),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: model.isSaving ? null : () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: model.isSaving
                ? null
                : () async {
                    if (!_formKey.currentState!.validate()) return;
                    final saved = await model.save();
                    if (saved && context.mounted) Navigator.pop(context, true);
                  },
            child: Text(model.isSaving ? 'Saving…' : 'Save renewal'),
          ),
        ],
      ),
    ),
  );
}
