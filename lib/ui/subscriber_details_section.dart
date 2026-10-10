import 'package:flutter/material.dart';

import 'subscriber_form_fields.dart';
import 'view_models/add_subscriber_form_view_model.dart';

class SubscriberDetailsSection extends StatelessWidget {
  const SubscriberDetailsSection({super.key, required this.viewModel});

  final AddSubscriberFormViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Subscriber details'),
        AppDropdownFormField(
          label: 'Subscriber type',
          value: viewModel.subscriberType,
          values: const {
            'individual': 'Individual',
            'organization': 'Organization',
          },
          onChanged: viewModel.setSubscriberType,
          validator: (value) =>
              viewModel.validateSelection(value, 'Subscriber type'),
        ),
        const SizedBox(height: 12),
        AppTextFormField(
          label: 'Name',
          initialValue: viewModel.name,
          onChanged: viewModel.setName,
          validator: (value) =>
              viewModel.validateRequired(value, 'Enter a name'),
        ),
        const SizedBox(height: 12),
        AppTextFormField(
          label: 'Contact person name',
          initialValue: viewModel.contactPersonName,
          onChanged: viewModel.setContactPersonName,
        ),
        const SizedBox(height: 12),
        AppTextFormField(
          label: 'Email',
          initialValue: viewModel.email,
          onChanged: viewModel.setEmail,
          keyboardType: TextInputType.emailAddress,
          validator: viewModel.validateEmail,
        ),
        const SizedBox(height: 12),
        AppTextFormField(
          label: 'Phone',
          initialValue: viewModel.phone,
          onChanged: viewModel.setPhone,
          keyboardType: TextInputType.phone,
          validator: viewModel.validatePhone,
        ),
        const SizedBox(height: 12),
        AppTextFormField(
          label: 'Postal address',
          initialValue: viewModel.postalAddress,
          onChanged: viewModel.setPostalAddress,
          maxLines: 2,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AppTextFormField(
                label: 'City',
                initialValue: viewModel.city,
                onChanged: viewModel.setCity,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextFormField(
                label: 'State',
                initialValue: viewModel.state,
                onChanged: viewModel.setState,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AppTextFormField(
                label: 'Postal code',
                initialValue: viewModel.postalCode,
                onChanged: viewModel.setPostalCode,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextFormField(
                label: 'Country',
                initialValue: viewModel.country,
                onChanged: viewModel.setCountry,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}
