import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sprout_ly_app/core/theme/app_colors.dart';
import 'package:sprout_ly_app/features/home/pages/home_page.dart';

void main() {
  testWidgets('HomePage does not render a floating bottom navigation card', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));

    expect(
      find.byWidgetPredicate((widget) {
        if (widget is! Container) {
          return false;
        }

        final decoration = widget.decoration;
        if (decoration is! BoxDecoration) {
          return false;
        }

        final borderRadius = decoration.borderRadius;
        return borderRadius is BorderRadius &&
            borderRadius.topLeft == const Radius.circular(64) &&
            borderRadius.topRight == const Radius.circular(64);
      }),
      findsNothing,
    );
  });
}
