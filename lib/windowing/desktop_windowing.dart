// The desktop windowing API is experimental in Flutter 3.47.
// ignore_for_file: implementation_imports, invalid_use_of_internal_member

import 'package:flutter/foundation.dart';
import 'package:flutter/src/foundation/_features.dart' show isWindowingEnabled;

bool get isDesktopPlatform =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows);

void enableDesktopWindowing() {
  // Opt in before WidgetsFlutterBinding creates its WindowingOwner. The
  // stable Flutter tool currently ignores enable-windowing in pubspec.yaml.
  if (isDesktopPlatform) isWindowingEnabled = true;
}
