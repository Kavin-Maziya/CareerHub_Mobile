
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:careerhub_mobile/main.dart';

void main() {
  testWidgets('CareerHub renders app bar, loading state, and job cards',
      (WidgetTester tester) async {
        // Force a narrow, phone-sized viewport so the LayoutBuilder picks
    // the single-column list, not the two-column grid -- avoids a
    // RenderFlex overflow in JobCard's location/employmentType row
    // when squeezed into a grid cell during testing.
    tester.view.physicalSize = const Size(500, 2800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    
    // ProviderScope is required -- HomeScreen is a ConsumerWidget.
    await tester.pumpWidget(const ProviderScope(child: CareerHubApp()));

    // App bar is visible immediately -- no async needed.
    expect(find.text('CareerHub'), findsOneWidget);

    // During the 1.5-second simulated load, a spinner should be visible.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Advance the fake timer past the 1500ms delay in JobsNotifier.build().
    await tester.pump(const Duration(seconds: 2));

    // Process the widget rebuild triggered by the provider moving to AsyncData.
    await tester.pumpAndSettle();

    // Spinner is gone -- data is loaded.
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // All four jobs from the provider should render.
    expect(find.text('Senior Frontend Software Engineer'), findsOneWidget);
    expect(find.text('UX/Web Designer'), findsOneWidget);
    expect(find.text('Data Analyst Intern'), findsOneWidget);
    expect(find.text('Part-Time Content Writer/Promoter'), findsOneWidget);

    // Status badges: 3 open jobs, 1 closed job.
    expect(find.text('Open'), findsNWidgets(3));
    expect(find.text('Closed'), findsOneWidget);

    // Filter chips render with the correct labels.
    expect(find.text('All'), findsOneWidget);
    // 'Remote' also appears twice: once as the filter chip, once as the
    // Part-Time Content Writer/Promoter job's location.
    expect(find.text('Remote'), findsNWidgets(2));
    // 'Full-Time' appears twice: once as the filter chip label, once in
    // the Senior Frontend Software Engineer card's employment-type row.
    expect(find.text('Full-Time'), findsNWidgets(2));

    // NEW: NavigationBar destination labels are new text nodes in the
    // tree that didn't exist before GoRouter's StatefulShellRoute.
    // 'Jobs' and 'Saved' don't collide with any existing text elsewhere
    // in the tree, so both are asserted as findsOneWidget.
    expect(find.text('Jobs'), findsOneWidget);
    expect(find.text('Saved'), findsOneWidget);
  });
}