import 'package:careerhub_mobile/models/auth_state.dart';
import 'package:careerhub_mobile/providers/auth_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ApplyScreen extends HookConsumerWidget {
  final String jobId;

  const ApplyScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Stable form key that survives rebuilds.
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());

    // Read once because the authenticated user's email
    // does not change while this screen is open.
    final auth = ref.read(authProvider);

    String email = '';

    if (auth is AsyncData<AuthState>) {
      final state = auth.value;

      if (state is Authenticated) {
        email = state.user.email;
      }
    }

    void submit() {
      if (formKey.currentState!.saveAndValidate()) {
        final values = formKey.currentState!.value;

        debugPrint(values.toString());

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Application submitted!')));

        Navigator.of(context).pop();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Apply'),
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FormBuilder(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FormBuilderTextField(
                name: 'full_name',
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  border: OutlineInputBorder(),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.minLength(2),
                ]),
              ),

              const SizedBox(height: 16),

              FormBuilderTextField(
                name: 'email',
                initialValue: email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.email(),
                ]),
              ),

              const SizedBox(height: 16),

              FormBuilderTextField(
                name: 'cover_letter',
                minLines: 5,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: 'Cover letter',
                  border: OutlineInputBorder(),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.minLength(50),
                ]),
              ),
              const SizedBox(height: 16),

              FormBuilderTextField(
                name: 'years_experience',
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Years of experience',
                  border: OutlineInputBorder(),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  (value) {
                    final years = int.tryParse(value ?? '');

                    if (years == null || years < 0) {
                      return 'Enter a valid non-negative number.';
                    }

                    return null;
                  },
                ]),
              ),

              const SizedBox(height: 16),

              FormBuilderDateTimePicker(
                name: 'start_date',
                inputType: InputType.date,
                decoration: const InputDecoration(
                  labelText: 'Earliest start date',
                  border: OutlineInputBorder(),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  (value) {
                    if (value == null) {
                      return null;
                    }

                    final selected = value.copyWith(
                      hour: 0,
                      minute: 0,
                      second: 0,
                      millisecond: 0,
                      microsecond: 0,
                    );

                    final today = DateTime.now().copyWith(
                      hour: 0,
                      minute: 0,
                      second: 0,
                      millisecond: 0,
                      microsecond: 0,
                    );

                    if (selected.isBefore(today)) {
                      return 'Start date cannot be in the past.';
                    }

                    return null;
                  },
                ]),
              ),

              const SizedBox(height: 16),

              FormBuilderTextField(
                name: 'portfolio_url',
                decoration: const InputDecoration(
                  labelText: 'Portfolio URL (optional)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return null;
                  }

                  return FormBuilderValidators.url()(value);
                },
              ),

              const SizedBox(height: 16),

              FormBuilderCheckbox(
                name: 'terms',
                title: const Text(
                  'I confirm my application is accurate and complete.',
                ),
                validator: (value) {
                  if (value != true) {
                    return 'You must accept the terms.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 24),

              FilledButton(
                onPressed: submit,
                child: const Text('Submit Application'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
