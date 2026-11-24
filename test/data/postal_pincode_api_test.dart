import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:vanithabodhini/data/postal_pincode_api.dart';

void main() {
  PostalPincodeApi apiReturning(String body, {int statusCode = 200}) {
    return PostalPincodeApi(
      client: MockClient((request) async {
        expect(request.url.host, 'api.postalpincode.in');
        expect(request.url.path, '/pincode/110001');
        return http.Response(
          body,
          statusCode,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );
  }

  test('parses comma-separated post office names', () async {
    final api = apiReturning(
      jsonEncode([
        {
          'Message': 'Number of pincode(s) found:2',
          'Status': 'Success',
          'PostOffice': [
            {'Name': 'Baroda House'},
            {'Name': ' Bengali Market '},
            {'Name': ''},
          ],
        },
      ]),
    );
    addTearDown(api.close);

    final result = await api.fetchPostOffices(' 110001 ');

    expect(result.pincode, '110001');
    expect(result.isSuccess, isTrue);
    expect(result.postOfficeNames, ['Baroda House', 'Bengali Market']);
    expect(result.namesAsText, 'Baroda House, Bengali Market');
  });

  test('treats an error response as no post offices', () async {
    final api = apiReturning(
      jsonEncode([
        {'Message': 'No records found', 'Status': 'Error', 'PostOffice': null},
      ]),
    );
    addTearDown(api.close);

    final result = await api.fetchPostOffices('110001');

    expect(result.isSuccess, isFalse);
    expect(result.postOfficeNames, isEmpty);
    expect(result.hasPostOffices, isFalse);
  });

  test('throws when the service returns a failure status', () async {
    final api = apiReturning('service unavailable', statusCode: 503);
    addTearDown(api.close);

    await expectLater(
      api.fetchPostOffices('110001'),
      throwsA(isA<PostalPincodeException>()),
    );
  });

  test('throws when the response is not valid JSON', () async {
    final api = apiReturning('not json');
    addTearDown(api.close);

    await expectLater(
      api.fetchPostOffices('110001'),
      throwsA(isA<PostalPincodeException>()),
    );
  });
}
