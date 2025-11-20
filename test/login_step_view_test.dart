import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:villavibe/features/auth/presentation/widgets/login_step_view.dart';

void main() {
  testWidgets('LoginStepView toggles between Phone and Email modes',
      (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: LoginStepView(
              onContinue: (_) {},
              onGoogleSignIn: () {},
            ),
          ),
        ),
      ),
    );

    // Initial State: Phone Mode
    expect(find.text('Phone number'), findsOneWidget);
    expect(find.text('Email'), findsNothing);
    expect(find.text('Continue with email'), findsOneWidget);
    expect(find.text('Continue with Phone'), findsNothing);

    // Switch to Email Mode
    await tester.tap(find.text('Continue with email'));
    await tester.pumpAndSettle();

    // Verify Email Mode
    expect(find.text('Phone number'), findsNothing);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Continue with email'), findsNothing);
    expect(find.text('Continue with Phone'), findsOneWidget);

    // Switch back to Phone Mode
    await tester.tap(find.text('Continue with Phone'));
    await tester.pumpAndSettle();

    // Verify Phone Mode again
    expect(find.text('Phone number'), findsOneWidget);
    expect(find.text('Email'), findsNothing);
    expect(find.text('Continue with email'), findsOneWidget);
    expect(find.text('Continue with Phone'), findsNothing);
  });
}
