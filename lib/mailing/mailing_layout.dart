enum MailingOrientation { portrait, landscape }

enum MailingOrdering { name, postalCode }

enum MailingLabelSize {
  small(60, 30),
  medium(65, 35),
  large(65, 40);

  const MailingLabelSize(this.widthMm, this.heightMm);

  final int widthMm;
  final int heightMm;

  String get label => '$widthMm × $heightMm mm';
}

class MailingLayout {
  const MailingLayout({
    this.orientation = MailingOrientation.portrait,
    this.labelSize = MailingLabelSize.small,
  });

  final MailingOrientation orientation;
  final MailingLabelSize labelSize;

  static const marginMm = 10.0;
  static const paddingMm = 2.0;
  static const maxFontSize = 12.0;
  static const minFontSize = 8.0;

  double get pageWidthMm =>
      orientation == MailingOrientation.portrait ? 210 : 297;
  double get pageHeightMm =>
      orientation == MailingOrientation.portrait ? 297 : 210;
  int get columns => ((pageWidthMm - 2 * marginMm) / labelSize.widthMm).floor();
  int get rowsPerPage =>
      ((pageHeightMm - 2 * marginMm) / labelSize.heightMm).floor();
  int get labelsPerPage => columns * rowsPerPage;
  double get contentWidthMm => labelSize.widthMm - 2 * paddingMm;
  double get contentHeightMm => labelSize.heightMm - 2 * paddingMm;

  int pageCount(int subscriberCount) =>
      (subscriberCount / labelsPerPage).ceil();

  MailingLabelPosition position(int index) {
    final onPage = index % labelsPerPage;
    return MailingLabelPosition(
      page: index ~/ labelsPerPage,
      leftMm: marginMm + (onPage % columns) * labelSize.widthMm,
      topMm: marginMm + (onPage ~/ columns) * labelSize.heightMm,
    );
  }
}

class MailingLabelPosition {
  const MailingLabelPosition({
    required this.page,
    required this.leftMm,
    required this.topMm,
  });

  final int page;
  final double leftMm;
  final double topMm;
}
