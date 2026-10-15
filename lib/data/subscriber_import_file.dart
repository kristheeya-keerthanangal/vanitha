import 'package:file_selector/file_selector.dart';

class SubscriberImportFile {
  const SubscriberImportFile({required this.name, required this.contents});

  final String name;
  final String contents;
}

Future<SubscriberImportFile?> selectSubscriberImportFile() async {
  final file = await openFile(
    acceptedTypeGroups: const [
      XTypeGroup(label: 'JSON', extensions: ['json']),
    ],
  );
  if (file == null) return null;
  return SubscriberImportFile(
    name: file.name,
    contents: await file.readAsString(),
  );
}
