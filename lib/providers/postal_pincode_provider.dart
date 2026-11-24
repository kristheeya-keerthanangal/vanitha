import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/postal_pincode_api.dart';

final postalPincodeApiProvider = Provider<PostalPincodeApi>((ref) {
  final api = PostalPincodeApi();
  ref.onDispose(api.close);
  return api;
});

final postalPincodeLookupProvider =
    FutureProvider.family<PostalPincodeResult, String>((ref, pincode) {
      return ref.watch(postalPincodeApiProvider).fetchPostOffices(pincode);
    }, retry: (retryCount, error) => null);
