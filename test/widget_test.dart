
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careerhub_mobile/main.dart';
import 'package:careerhub_mobile/models/job.dart';
import 'package:careerhub_mobile/providers/jobs_notifier.dart';

// Fake notifier defined in the test file, not the main codebase.
// Extends the PUBLIC JobsNotifier class, not _$JobsNotifier -- the
// leading underscore makes _$JobsNotifier private to jobs_notifier.dart,
// so no other file (including this test) can extend it directly.
class _FakeJobsNotifier extends JobsNotifier {
  @override
  Future<List<Job>> build() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    return [
      Job(
        id: '1',
        title: 'Senior Frontend Software Engineer',
        company: 'TechCorp Cape Town',
        location: 'Cape Town',
        description: 'We are looking for a talented Senior Frontend Engineer...',
        employmentType: 'FullTime',
        isOpen: true,
        salaryDisplay: 'R37500 per month',
        closingDate: DateTime(2026, 7, 24),
      ),
      Job(
        id: '2',
        title: 'UX/Web Designer',
        company: 'DesignHouse Sandton',
        location: 'Sandton',
        description: 'We are looking for a creative UX/Web Designer...',
        employmentType: 'Contract',
        isOpen: true,
      ),
      Job.closed(
        id: '3',
        title: 'Data Analyst Intern',
        company: 'DataWorks Pretoria',
        location: 'Pretoria/Hybrid',
        description: 'We are looking for a Data Analyst Intern...',
        employmentType: 'Internship',
        salaryDisplay: 'R18500 per month',
        closingDate: DateTime(2026, 6, 19),
      ),
      Job.remote(
        id: '4',
        title: 'Part-Time Content Writer/Promoter',
        company: 'MediaCo',
        description: 'We are looking for a Content Writer...',
        employmentType: 'PartTime',
        isOpen: true,
        salaryDisplay: 'R15000 per month',
        closingDate: DateTime(2026, 7, 24),
      ),
    ];
  }
}

void main() {
  testWidgets('CareerHub renders app bar, loading state, job cards, and nav bar',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(500, 2800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    // Override jobsProvider with the fake notifier -- no real network
    // call happens during this test.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          jobsProvider.overrideWith(_FakeJobsNotifier.new),
        ],
        child: const CareerHubApp(),
      ),
    );

    expect(find.text('CareerHub'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);

    expect(find.text('Senior Frontend Software Engineer'), findsOneWidget);
    expect(find.text('UX/Web Designer'), findsOneWidget);
    expect(find.text('Data Analyst Intern'), findsOneWidget);
    expect(find.text('Part-Time Content Writer/Promoter'), findsOneWidget);

    expect(find.text('Open'), findsNWidgets(3));
    expect(find.text('Closed'), findsOneWidget);

    expect(find.text('All'), findsOneWidget);
    expect(find.text('Remote'), findsNWidgets(2));
    expect(find.text('Full-Time'), findsNWidgets(2));

    expect(find.text('Jobs'), findsOneWidget);
    expect(find.text('Saved'), findsOneWidget);
  });
}