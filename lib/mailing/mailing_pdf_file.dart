import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';

class MailingPdfFile {
  Future<bool> save(Uint8List bytes) async {
    final location = await getSaveLocation(
      suggestedName: 'mailing-labels.pdf',
      acceptedTypeGroups: const [
        XTypeGroup(label: 'PDF', extensions: ['pdf']),
      ],
    );
    if (location == null) return false;
    await XFile.fromData(
      bytes,
      mimeType: 'application/pdf',
      name: 'mailing-labels.pdf',
    ).saveTo(location.path);
    return true;
  }
}
