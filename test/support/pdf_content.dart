import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

// Inspect PDFs generated with a single embedded font, decoding its character
// map so tests assert the text a reader receives rather than font glyph IDs.
List<String> nativePdfPageStreams(Uint8List bytes) {
  final streams = <String>[];
  for (final match in RegExp(
    r'stream\n(.*?)\nendstream',
    dotAll: true,
  ).allMatches(latin1.decode(bytes))) {
    try {
      streams.add(latin1.decode(zlib.decode(latin1.encode(match[1]!))));
    } on FormatException {
      // Non-content streams may use a different encoding.
    }
  }
  final cmap = streams.singleWhere((stream) => stream.contains('beginbfchar'));
  final mappings = cmap.split('beginbfchar').last.split('endbfchar').first;
  final characters = <int, int>{
    for (final match in RegExp(
      r'<([\dA-F]+)> <([\dA-F]+)>',
    ).allMatches(mappings))
      int.parse(match[1]!, radix: 16): int.parse(match[2]!, radix: 16),
  };
  return [
    for (final stream in streams.where((stream) => stream.contains('BT')))
      stream.replaceAllMapped(RegExp(r'<([\da-fA-F]+)>'), (match) {
        final codes = match[1]!;
        return '(${String.fromCharCodes([for (var offset = 0; offset < codes.length; offset += 4) characters[int.parse(codes.substring(offset, offset + 4), radix: 16)]!])})';
      }),
  ];
}
