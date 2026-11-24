import 'dart:async';

import 'package:vanithabodhini/data/repositories/subscriber_repository.dart';

class ControlledMailingListRepository extends SubscriberRepository {
  ControlledMailingListRepository(super.database);

  final requests = <Completer<List<MailingListEntry>>>[];
  final filters = <MailingListFilter>[];

  @override
  Future<List<MailingListEntry>> getMailingList({
    MailingListFilter filter = MailingListFilter.active,
  }) {
    filters.add(filter);
    final request = Completer<List<MailingListEntry>>();
    requests.add(request);
    return request.future;
  }
}

const mailingEntries = [
  MailingListEntry(
    subscriberId: 3,
    name: 'Anita',
    postalAddress: 'Street A',
    postalCode: '682001',
  ),
  MailingListEntry(
    subscriberId: 2,
    name: 'Bela',
    postalAddress: 'Street B',
    postalCode: '110001',
  ),
  MailingListEntry(
    subscriberId: 1,
    name: 'Chitra',
    postalAddress: null,
    postalCode: '110001',
  ),
  MailingListEntry(
    subscriberId: 5,
    name: 'Deepa',
    postalAddress: '  ',
    postalCode: null,
  ),
  MailingListEntry(
    subscriberId: 4,
    name: 'Elsa',
    postalAddress: 'Street E',
    postalCode: ' \t ',
  ),
];
