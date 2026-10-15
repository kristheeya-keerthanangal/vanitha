# Mailing-label PDFs

The mailing list includes every non-archived subscriber, irrespective of edition
or subscription status. The current Name or PIN code ordering is used for the PDF.
Incomplete details are flagged in the page, but subscribers remain included and
warning text is never added to labels.

The agreed layout uses A4 paper in portrait or landscape, 10 mm margins on every
side, no gaps between labels, and 2 mm padding inside each label. Labels retain
their selected dimensions: 60 × 30, 65 × 35, or 65 × 40 mm. Only whole labels fit
within the margins. Labels fill from left to right, then top to bottom; a row
that cannot fit starts on the next page. The default portrait layout holds
three columns and nine rows of 60 × 30 mm labels.

Text starts at 12 pt and reduces in 0.5 pt steps to a minimum of 8 pt. The same
PDF text layout measures and renders each English label using built-in Helvetica.
Text remains searchable and selectable, with no raster images or bundled font
files. Page sizes, label positions, and optional light grey 0.25 pt cutting guides
use PDF points with an exact conversion from millimetres.

Every label is checked before creating pages. If any text cannot fit at 8 pt,
no document is saved. The page lists affected subscribers and asks the user to
correct their details or select a larger label. Returning from subscriber details
refreshes the list; changing label dimensions also clears the failed attempt so
generation can validate the revised layout.

Use **Preview PDF** to generate an embedded, scrollable preview of every page.
Each preview captures an immutable copy of the loaded subscribers, their order,
and the selected layout and cutting-guide settings. The viewer uses those PDF
bytes directly and does not offer separate paper or orientation controls.

Changing any setting or refreshing subscriber data immediately clears the
preview and prompts regeneration. Results from earlier requests are ignored,
including requests still running when the selection changes. Generation and
page rendering show progress; errors offer retry guidance. Preview is disabled
while loading, for an empty list, or until known fitting failures are corrected.

Once a current preview exists, use **Print PDF** to open the platform print
dialog or **Save PDF** to choose a location with the existing file selector.
Both actions use the exact preview bytes without regenerating the document.
Printing requests the preview's A4 dimensions and disables dynamic relayout.
Choose **100% / actual size** and turn off **Fit to page** in the print dialog
to preserve label dimensions.

Print and Save are disabled without a current PDF, during preview generation,
and while either output dialog is active. Settings and refresh are also locked
during output. Cancellation leaves the preview available; failures explain how
to retry with a working printer or a writable save location.
