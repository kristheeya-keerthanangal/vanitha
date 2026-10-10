import 'package:flutter/material.dart';

import 'app_text_form_field.dart';
import 'app_dropdown_form_field.dart';
import 'start_date_form_field.dart';
import '../view_models/add_subscriber_form_view_model.dart';

class SubscriptionDetailsSection extends StatelessWidget {
  const SubscriptionDetailsSection({super.key, required this.viewModel});

  final AddSubscriberFormViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text('Subscription details'),
        ),
        Row(
          children: [
            Expanded(
              child: AppDropdownFormField(
                label: 'Edition',
                value: viewModel.edition,
                values: const {'online': 'Online', 'offline': 'Offline'},
                onChanged: viewModel.setEdition,
                validator: (value) =>
                    viewModel.validateSelection(value, 'Edition'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppDropdownFormField(
                label: 'Plan type',
                value: viewModel.planType,
                values: const {
                  'annual': 'Annual',
                  'multi_year': 'Multi-year',
                  'lifetime': 'Lifetime',
                },
                onChanged: viewModel.setPlanType,
                validator: (value) =>
                    viewModel.validateSelection(value, 'Plan type'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            if (viewModel.showsDuration) ...[
              Expanded(
                child: AppTextFormField(
                  label: 'Duration (years)',
                  initialValue: viewModel.durationYears,
                  onChanged: viewModel.setDurationYears,
                  keyboardType: TextInputType.number,
                  validator: viewModel.validateDuration,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: StartDateFormField(
                value: viewModel.startDate,
                onChanged: viewModel.setStartDate,
                validator: (_) =>
                    viewModel.startDate == null ? 'Select a start date' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AppDropdownFormField(
          label: 'Payment status',
          value: viewModel.paymentStatus,
          values: const {'paid': 'Paid', 'unpaid': 'Unpaid'},
          onChanged: viewModel.setPaymentStatus,
          validator: (value) =>
              viewModel.validateSelection(value, 'Payment status'),
        ),
      ],
    );
  }
}
