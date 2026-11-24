import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class PostalPincodeResult {
  const PostalPincodeResult({
    required this.pincode,
    required this.postOfficeNames,
    required this.isSuccess,
  });

  final String pincode;
  final List<String> postOfficeNames;
  final bool isSuccess;

  bool get hasPostOffices => postOfficeNames.isNotEmpty;

  String get namesAsText => postOfficeNames.join(', ');
}

class PostalPincodeException implements Exception {
  const PostalPincodeException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Looks up Indian post offices for a PIN code using the India Post API.
class PostalPincodeApi {
  PostalPincodeApi({http.Client? client}) : _client = client ?? http.Client();

  static const _timeout = Duration(seconds: 10);
  static const _baseUrl = 'https://api.postalpincode.in/pincode';

  final http.Client _client;

  Future<PostalPincodeResult> fetchPostOffices(String pincode) async {
    final normalized = pincode.trim();
    final http.Response response;
    try {
      response = await _client
          .get(
            Uri.parse('$_baseUrl/$normalized'),
            headers: const {'Accept': 'application/json'},
          )
          .timeout(_timeout);
    } on TimeoutException {
      throw const PostalPincodeException('The post office lookup timed out.');
    } on Exception catch (error) {
      throw PostalPincodeException(
        'Could not reach the post office service: $error',
      );
    }

    if (response.statusCode != 200) {
      throw PostalPincodeException(
        'The post office service returned ${response.statusCode}.',
      );
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw const PostalPincodeException(
        'The post office service returned invalid data.',
      );
    }

    if (decoded is! List || decoded.isEmpty || decoded.first is! Map) {
      throw const PostalPincodeException(
        'The post office service returned invalid data.',
      );
    }

    final payload = decoded.first as Map;
    final isSuccess = payload['Status']?.toString().toLowerCase() == 'success';
    final names = <String>[];
    final postOffices = payload['PostOffice'];
    if (isSuccess && postOffices is List) {
      for (final entry in postOffices) {
        if (entry is! Map) continue;
        final name = entry['Name']?.toString().trim() ?? '';
        if (name.isNotEmpty) names.add(name);
      }
    }

    return PostalPincodeResult(
      pincode: normalized,
      postOfficeNames: names,
      isSuccess: isSuccess,
    );
  }

  void close() => _client.close();
}
