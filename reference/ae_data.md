# Simulated adverse events of a two-arm trial

Simulated adverse events (534 events in 172 of the 271 participants of
\[baseline_data\]), used in the examples, tests and vignette. The data
are entirely simulated (see \`data-raw/simulate_data.R\` in the source
package); they do not describe real people. The same data are in
\`inst/extdata/ae_data.csv\`; \`inst/extdata/group_data.csv\` classifies
the event terms.

## Usage

``` r
ae_data
```

## Format

A data frame with 534 rows and 6 columns:

- usubjid:

  participant ID, as in \[baseline_data\]

- ctcaename:

  CTCAE term of the event

- ctcaegrade:

  grade, \`"I"\` to \`"IV"\` (a few missing)

- original_ctcaegrade:

  grade originally reported (often missing)

- posrelunrel:

  relation to treatment: \`"POSREL"\`, \`"REL"\` or \`"UNREL"\`

- unexp:

  unexpected event, \`"Y"\` or \`"N"\`

## Source

Simulated with \`data-raw/simulate_data.R\`.

## See also

\[baseline_data\], \[sstable.ae()\]
