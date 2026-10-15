import 'package:flutter_test/flutter_test.dart';
import 'package:vanithabodhini/mailing/mailing_layout.dart';

void main() {
  test('default layout has three columns and nine complete rows', () {
    const layout = MailingLayout();
    expect(layout.columns, 3);
    expect(layout.rowsPerPage, 9);
    expect(layout.labelsPerPage, 27);
    expect(layout.pageCount(0), 0);
    expect(layout.pageCount(27), 1);
    expect(layout.pageCount(28), 2);
    expect(layout.contentWidthMm, 56);
    expect(layout.contentHeightMm, 26);
  });

  for (final orientation in MailingOrientation.values) {
    for (final size in MailingLabelSize.values) {
      test(
        '$orientation $size preserves margins, dimensions, and row boundaries',
        () {
          final layout = MailingLayout(
            orientation: orientation,
            labelSize: size,
          );
          for (var i = 0; i < layout.labelsPerPage * 2 + 1; i++) {
            final position = layout.position(i);
            expect(position.leftMm, greaterThanOrEqualTo(10));
            expect(position.topMm, greaterThanOrEqualTo(10));
            expect(
              position.leftMm + size.widthMm,
              lessThanOrEqualTo(layout.pageWidthMm - 10),
            );
            expect(
              position.topMm + size.heightMm,
              lessThanOrEqualTo(layout.pageHeightMm - 10),
            );
            if (i % layout.columns != 0) {
              final previous = layout.position(i - 1);
              expect(position.page, previous.page);
              expect(position.topMm, previous.topMm);
              expect(position.leftMm - previous.leftMm, size.widthMm);
            }
          }
          final last = layout.position(layout.labelsPerPage - 1);
          final next = layout.position(layout.labelsPerPage);
          expect(last.page, 0);
          expect(next.page, 1);
          expect(next.leftMm, 10);
          expect(next.topMm, 10);
          expect(layout.position(layout.columns).topMm, 10 + size.heightMm);
        },
      );
    }
  }
}
