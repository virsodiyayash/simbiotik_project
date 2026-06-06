import 'package:flutter_test/flutter_test.dart';

import 'package:practice_flutter/app.dart';

void main() {
  testWidgets('HireHub shell renders', (WidgetTester tester) async {
    await tester.pumpWidget(const HireHubApp());
    await tester.pump();

    expect(find.text('HireHub'), findsOneWidget);
    expect(find.text('Search by title or company'), findsOneWidget);
  });
}
