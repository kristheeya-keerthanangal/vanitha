# Mailing-label verification — 15 October 2026

Automated and native software checks passed. Physical paper measurements are
still pending; this verification is not complete until those measurements are
recorded.

## Automated coverage

`flutter analyze` reported no issues. The normal `lib/main.dart` Linux debug
build passed after restoring it from the isolated verification entrypoint.

`flutter test` passed all 244 tests, including the new
`test/mailing/mailing_workflow_test.dart` matrix and the navigation-through-output
widget test in `test/ui/mailing_pdf_preview_test.dart`.

The matrix exercises all 24 combinations of three label sizes, two orientations,
two orderings, and cutting guides on/off. It uses a real in-memory Drift database,
subscriber repository, PDF generator, and file writes. The platform print dialog
boundary is simulated, and its layout callback must return the same bytes as the
preview and saved file, even if the printer requests different paper dimensions.

Covered cases include:

- Zero subscribers: preview, save, and print are disabled.
- Missing and blank addresses/PIN codes: subscribers remain included, warnings
  are counted, and warning text is omitted from labels.
- Long addresses: text shrinks within the allowed range; failures block output;
  a larger label permits generation when the text fits.
- Impossible addresses: output remains blocked even with the largest label.
- Multiple pages: each included subscriber appears once, whole rows remain
  together, and both orderings preserve deterministic ID ties and missing PINs last.
- Archive exclusion, stale-preview invalidation, cancellation, output errors,
  retry, and action locking while a dialog is active.

## Native Linux workflow

An isolated application used 32 synthetic subscribers in an in-memory database.
The native checks exercised Dashboard → Mailing list, incomplete-detail warnings,
blocked generation for a long address, selection of a larger label, a three-page
PDF preview, the file-selector save dialog, and the GTK print dialog. Native
save and print cancellation also returned to the current preview.

GTK's **Print to File** destination was used with **A4 portrait, 100% scale**.
Its output and **Save PDF** were byte-for-byte identical:

```text
SHA-256: 2f9c51f90363468135006f2a11b541898a6d3ce2f0014d00bd0ca8b027f77a36
Pages: 3
Labels per page: 12, 12, 8
Label size: 65 × 40 mm
Page size: 210 × 297 mm
```

The configured physical printer was disabled with an existing pending job. Its
queue was left unchanged. No successful paper print or ruler measurement is
claimed.

## Large-list preview regression

A native Linux debug build with 930 synthetic subscribers produced a 35-page
PDF. The original preview rasterized all pages and reached a process peak
resident memory of 2,310,860 KiB (about 2.2 GiB). The process survived on this test
machine; the reported crash on the user's machine was not reproduced directly.

The preview now requests one selected page at 144 dpi, with first, previous,
next, and last page controls. Print and save continue to use the complete PDF.
Regression tests cover 930 generated labels across 35 pages, bounded native
raster requests, page navigation, resetting a new preview to its first page,
and avoiding extra raster requests during save/print notifications.

## A4 samples and paper measurements

Six one-page samples were generated with the production PDF generator and light
cutting guides. Independent PDF-stream inspection verified these digital sizes
to within 0.001 mm:

| Label | Orientation | Page (mm) | Columns × rows | Labels |
|---|---|---|---|---|
| 60 × 30 mm | Portrait | 210 × 297 | 3 × 9 | 27 |
| 60 × 30 mm | Landscape | 297 × 210 | 4 × 6 | 24 |
| 65 × 35 mm | Portrait | 210 × 297 | 2 × 7 | 14 |
| 65 × 35 mm | Landscape | 297 × 210 | 4 × 5 | 20 |
| 65 × 40 mm | Portrait | 210 × 297 | 2 × 6 | 12 |
| 65 × 40 mm | Landscape | 297 × 210 | 4 × 4 | 16 |

Print an A4 sample at **100% / actual size**, with **Fit to page off** and
**one page per sheet**. Measure between the centres of the cutting guides.
Check labels near the top and bottom of the sheet to detect scaling or feed
differences. Record the printer, driver, selected settings, and ruler readings.
Digital dimensions do not establish the dimensions of a physical printout.

| Physical check | Result |
|---|---|
| Printer and driver | Pending |
| A4 and 100% / actual size confirmed | Pending |
| Selected label size | Pending |
| Measured width × height near top | Pending |
| Measured width × height near bottom | Pending |
