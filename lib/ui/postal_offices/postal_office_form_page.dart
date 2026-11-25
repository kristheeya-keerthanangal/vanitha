import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../providers/database_provider.dart';
import '../shared/error_state.dart';
import '../shared/loading_state.dart';
import 'view_models/postal_office_form_view_model.dart';

class PostalOfficeFormPage extends ConsumerStatefulWidget {
  const PostalOfficeFormPage({super.key, this.id});

  final int? id;

  @override
  ConsumerState<PostalOfficeFormPage> createState() =>
      _PostalOfficeFormPageState();
}

class _PostalOfficeFormPageState extends ConsumerState<PostalOfficeFormPage> {
  late final PostalOfficeFormViewModel _model;

  @override
  void initState() {
    super.initState();
    _model = PostalOfficeFormViewModel(
      ref.read(postalOfficeRepositoryProvider),
      officeId: widget.id != null && widget.id! > 0 ? widget.id : null,
    );
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _model,
      builder: (context, _) {
        if (_model.loading) {
          return const Scaffold(body: Center(child: LoadingState()));
        }

        if (_model.loadError != null) {
          return Scaffold(
            appBar: AppBar(leading: const BackButton()),
            body: ErrorState(
              message: _model.loadError!,
              onRetry: () => context.pop(),
            ),
          );
        }

        final title = _model.isEdit ? 'Edit postal office' : 'Add postal office';

        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Back',
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildOfficeDetailsCard(),
                    const SizedBox(height: 24),
                    _buildRulesCard(),
                    const SizedBox(height: 24),
                    _buildTesterCard(),
                    const SizedBox(height: 24),
                    if (_model.saveError != null) ...[
                      Card(
                        color: Theme.of(context).colorScheme.errorContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            _model.saveError!,
                            style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.onErrorContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: _model.isSaving
                              ? null
                              : () => Navigator.of(context).maybePop(),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        FilledButton.icon(
                          onPressed: _model.isSaving ? null : _save,
                          icon: _model.isSaving
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.save),
                          label: Text(_model.isEdit ? 'Save changes' : 'Create office'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOfficeDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Office details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _model.nameController,
              decoration: const InputDecoration(
                labelText: 'Office name *',
                hintText: 'e.g. Kasaragod RMS, Kannur RMS, Thalassery STO',
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Active'),
              subtitle: const Text(
                'Inactive offices cannot be selected for filtering subscriptions',
              ),
              value: _model.isActive,
              onChanged: _model.setIsActive,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRulesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pincode rules',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'A subscription matches if it meets at least one Include rule and no Exclude rules.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _model.addRule,
                  icon: const Icon(Icons.add),
                  label: const Text('Add rule'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_model.rules.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'No rules configured. Click "Add rule" to define Include or Exclude rules.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _model.rules.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildRuleRow(index, _model.rules[index]);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleRow(int index, RuleDraft rule) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 600;

          final operationSelector = DropdownButtonFormField<String>(
            key: ValueKey('op_${rule.id}_${rule.operation}'),
            initialValue: rule.operation,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Operation',
              isDense: true,
            ),
            items: const [
              DropdownMenuItem(value: 'include', child: Text('Include')),
              DropdownMenuItem(value: 'exclude', child: Text('Exclude')),
            ],
            onChanged: (val) {
              if (val != null) _model.setRuleOperation(index, val);
            },
          );

          final methodSelector = DropdownButtonFormField<String>(
            key: ValueKey('method_${rule.id}_${rule.matchMethod}'),
            initialValue: rule.matchMethod,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Method',
              isDense: true,
            ),
            items: const [
              DropdownMenuItem(value: 'prefix', child: Text('Prefix')),
              DropdownMenuItem(value: 'range', child: Text('Range')),
              DropdownMenuItem(value: 'exact', child: Text('Exact')),
            ],
            onChanged: (val) {
              if (val != null) _model.setRuleMatchMethod(index, val);
            },
          );

          final valueFields = rule.matchMethod == 'range'
              ? Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: rule.startController,
                        decoration: const InputDecoration(
                          labelText: 'Start PIN',
                          hintText: 'e.g. 670101',
                          isDense: true,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('–'),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: rule.endController,
                        decoration: const InputDecoration(
                          labelText: 'End PIN',
                          hintText: 'e.g. 670107',
                          isDense: true,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                )
              : TextFormField(
                  controller: rule.startController,
                  decoration: InputDecoration(
                    labelText: rule.matchMethod == 'prefix'
                        ? 'PIN Prefix'
                        : 'Exact PIN',
                    hintText: rule.matchMethod == 'prefix'
                        ? 'e.g. 671'
                        : 'e.g. 689590',
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                );

          final deleteButton = IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Remove rule',
            color: Theme.of(context).colorScheme.error,
            onPressed: () => _model.removeRule(index),
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: operationSelector),
                    const SizedBox(width: 8),
                    Expanded(child: methodSelector),
                    deleteButton,
                  ],
                ),
                const SizedBox(height: 8),
                valueFields,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 130, child: operationSelector),
              const SizedBox(width: 12),
              SizedBox(width: 130, child: methodSelector),
              const SizedBox(width: 12),
              Expanded(child: valueFields),
              const SizedBox(width: 8),
              deleteButton,
            ],
          );
        },
      ),
    );
  }

  Widget _buildTesterCard() {
    final result = _model.testResult;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pincode assignment tester',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Enter a 6-digit pincode to test whether it matches this office based on configured rules.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _model.testPincodeController,
                    decoration: const InputDecoration(
                      labelText: 'Test pincode',
                      hintText: 'Enter 6-digit PIN (e.g. 671001)',
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    onFieldSubmitted: (_) => _model.runPincodeTest(),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.tonalIcon(
                  onPressed: _model.runPincodeTest,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Test'),
                ),
              ],
            ),
            if (result != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: result.matches
                      ? Colors.green.withValues(alpha: 0.12)
                      : Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: result.matches
                        ? Colors.green
                        : Theme.of(context).colorScheme.error,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          result.matches ? Icons.check_circle : Icons.cancel,
                          color: result.matches
                              ? Colors.green
                              : Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          result.matches
                              ? 'MATCHES THIS OFFICE'
                              : 'DOES NOT MATCH',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: result.matches
                                ? Colors.green.shade800
                                : Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (result.matchedIncludeRule != null)
                      Text(
                        '• Matched Include rule: ${result.matchedIncludeRule!.matchMethod.toUpperCase()} (${result.matchedIncludeRule!.startValue}${result.matchedIncludeRule!.endValue != null ? ' to ${result.matchedIncludeRule!.endValue}' : ''})',
                      ),
                    if (result.blockedByExcludeRule != null)
                      Text(
                        '• Prevented by Exclude rule: ${result.blockedByExcludeRule!.matchMethod.toUpperCase()} (${result.blockedByExcludeRule!.startValue}${result.blockedByExcludeRule!.endValue != null ? ' to ${result.blockedByExcludeRule!.endValue}' : ''})',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (result.reason != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          result.reason!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final success = await _model.save();
    if (success && mounted) {
      final navigator = Navigator.of(context);
      if (navigator.canPop()) {
        navigator.pop(true);
      } else {
        try {
          context.go('/postal-offices');
        } catch (_) {}
      }
    }
  }
}
