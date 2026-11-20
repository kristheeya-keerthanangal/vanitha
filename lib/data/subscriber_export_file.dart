import 'dart:convert';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';

Future<bool> saveSubscriberExportFile(String contents) async {
  final location = await getSaveLocation(
    suggestedName: 'subscribers.json',
    acceptedTypeGroups: const [
      XTypeGroup(label: 'JSON', extensions: ['json']),
    ],
  );
  if (location == null) return false;
  await XFile.fromData(
    Uint8List.fromList(utf8.encode(contents)),
    mimeType: 'application/json',
    name: 'subscribers.json',
  ).saveTo(location.path);
  return true;
}
