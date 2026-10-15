import 'dart:typed_data';

import '../data/repositories/subscriber_repository.dart';
import 'mailing_layout.dart';

class MailingPdfSnapshot {
  MailingPdfSnapshot({
    required List<MailingListEntry> subscribers,
    required this.layout,
    required this.ordering,
    required this.cuttingGuides,
  }) : subscribers = List.unmodifiable(subscribers);

  final List<MailingListEntry> subscribers;
  final MailingLayout layout;
  final MailingOrdering ordering;
  final bool cuttingGuides;

  int get pageCount => layout.pageCount(subscribers.length);
}

class MailingPdfPreview {
  MailingPdfPreview({required this.snapshot, required Uint8List bytes})
    : bytes = Uint8List.fromList(bytes).asUnmodifiableView();

  final MailingPdfSnapshot snapshot;
  final Uint8List bytes;
}
