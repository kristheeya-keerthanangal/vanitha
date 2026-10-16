// ignore_for_file: implementation_imports, invalid_use_of_internal_member

import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter/src/widgets/_window.dart';
import 'package:flutter_test/flutter_test.dart';

class FakePreviewWindowOwner implements WindowingOwner {
  FakePreviewWindowOwner(this.tester);

  final WidgetTester tester;
  final windows = <FakePreviewWindowController>[];

  @override
  RegularWindowController createRegularWindowController({
    required RegularWindowControllerDelegate delegate,
    Size? size,
    BoxConstraints? constraints,
    required bool resizable,
    String? title,
  }) {
    final window = FakePreviewWindowController(
      _PreviewView(tester.view, windows.length + 100),
      delegate,
      title!,
    );
    windows.add(window);
    return window;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakePreviewWindowController extends RegularWindowController {
  FakePreviewWindowController(FlutterView view, this.delegate, this.title)
    : super.empty() {
    rootView = view;
  }

  final RegularWindowControllerDelegate delegate;
  bool destroyed = false;
  bool disposed = false;

  @override
  final String title;
  @override
  Size get contentSize => const Size(1000, 800);
  @override
  bool get isActivated => true;
  @override
  bool get isMaximized => false;
  @override
  bool get isMinimized => false;
  @override
  bool get isFullscreen => false;

  @override
  void activate() {}

  @override
  void destroy() {
    if (destroyed) return;
    destroyed = true;
    delegate.onWindowDestroyed();
  }

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _PreviewView extends TestFlutterView {
  _PreviewView(TestFlutterView view, this.viewId)
    : super(
        view: view,
        platformDispatcher: view.platformDispatcher,
        display: view.display,
      );

  @override
  final int viewId;

  // Only the implicit test view submits scenes and semantics to the engine.
  @override
  void render(Scene scene, {Size? size}) {}

  @override
  void updateSemantics(SemanticsUpdate update) {}
}
