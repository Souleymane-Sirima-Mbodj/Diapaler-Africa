import 'package:flutter_test/flutter_test.dart';

import 'package:diapaler_africa/main.dart';

void main() {
  testWidgets('App boots on the role-selection screen', (tester) async {
    await tester.pumpWidget(const DiapalerApp());
    await tester.pumpAndSettle();

    expect(find.text('Je suis...'), findsOneWidget);
    expect(find.text('CONTINUER'), findsOneWidget);
    expect(find.text('Entrepreneur'), findsOneWidget);
    expect(find.text('Mentor'), findsOneWidget);
    expect(find.text('Investisseur'), findsOneWidget);
  });
}
