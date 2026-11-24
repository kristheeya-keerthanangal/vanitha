import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:vanithabodhini/data/postal_pincode_api.dart';
import 'package:vanithabodhini/providers/postal_pincode_provider.dart';
import 'package:vanithabodhini/ui/subscribers/widgets/pincode_lookup_card.dart';

void main() {
  Widget mount(String pincode, MockClient client) => ProviderScope(
    overrides: [
      postalPincodeApiProvider.overrideWithValue(
        PostalPincodeApi(client: client),
      ),
    ],
    child: MaterialApp(
      home: Scaffold(body: PincodeLookupCard(pincode: pincode)),
    ),
  );

  MockClient successClient() => MockClient(
    (_) async => http.Response(
      jsonEncode([
        {
          'Message': 'Number of pincode(s) found:2',
          'Status': 'Success',
          'PostOffice': [
            {'Name': 'Baroda House'},
            {'Name': 'Bengali Market'},
          ],
        },
      ]),
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
    ),
  );

  testWidgets('renders only for a six-digit pincode', (tester) async {
    await tester.pumpWidget(mount('56000', successClient()));

    expect(find.byType(Card), findsNothing);
    expect(find.textContaining('Post offices'), findsNothing);
  });

  testWidgets('shows post office names comma separated', (tester) async {
    await tester.pumpWidget(mount('110001', successClient()));
    await tester.pumpAndSettle();

    expect(find.text('Post offices for 110001'), findsOneWidget);
    expect(find.text('Baroda House, Bengali Market'), findsOneWidget);
  });

  testWidgets('shows a message when no post office is found', (tester) async {
    final client = MockClient(
      (_) async => http.Response(
        jsonEncode([
          {
            'Message': 'No records found',
            'Status': 'Error',
            'PostOffice': null,
          },
        ]),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      ),
    );

    await tester.pumpWidget(mount('999999', client));
    await tester.pumpAndSettle();

    expect(find.text('No post office found for 999999.'), findsOneWidget);
  });

  testWidgets('shows an error with retry that refetches', (tester) async {
    var calls = 0;
    final client = MockClient((_) async {
      calls++;
      if (calls == 1) {
        return http.Response('service unavailable', 503);
      }
      return http.Response(
        jsonEncode([
          {
            'Message': 'found',
            'Status': 'Success',
            'PostOffice': [
              {'Name': 'Baroda House'},
            ],
          },
        ]),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });

    await tester.pumpWidget(mount('110001', client));
    await tester.pumpAndSettle();

    expect(find.text('Could not load post office details.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(calls, 2);
    expect(find.text('Baroda House'), findsOneWidget);
    expect(find.text('Could not load post office details.'), findsNothing);
  });
}
