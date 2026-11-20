import 'package:material_ui/material_ui.dart';

import 'app_text_form_field.dart';
import '../view_models/add_subscriber_form_view_model.dart';

class SubscriberDetailsSection extends StatelessWidget {
  const SubscriberDetailsSection({super.key, required this.viewModel});

  final AddSubscriberFormViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Subscriber details'),
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
          label: 'Address',
          initialValue: viewModel.postalAddress,
          onChanged: viewModel.setPostalAddress,
          maxLines: 2,
        ),
        const SizedBox(height: 12),
        AppTextFormField(
          label: 'Pincode',
          initialValue: viewModel.postalCode,
          onChanged: viewModel.setPostalCode,
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
