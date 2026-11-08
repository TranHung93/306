# Simulated baseline data of a two-arm trial

Simulated baseline characteristics of 271 participants in a two-arm
randomised trial in tetanus ("Intrathecal treatment" vs "Sham
procedure"), used in the examples, tests and vignette. The data are
entirely simulated (see \`data-raw/simulate_data.R\` in the source
package); they do not describe real people. The same data are in
\`inst/extdata/baseline_data.csv\`.

## Usage

``` r
baseline_data
```

## Format

A data frame with 271 rows and 61 columns:

- usubjid:

  participant ID, \`"SIM-001"\` to \`"SIM-271"\`

- age:

  age in years (integer)

- sex:

  \`"F"\` or \`"M"\`

- bmi:

  body mass index (kg/m^2)

- source:

  source of admission, coded 1 or 2

- tetanus:

  tetanus diagnosis, always \`"Y"\`

- icudays:

  days in the intensive care unit (a few missing)

- outcome:

  outcome, coded 2, 3 or 4

- hypertension, myocardialinfart, angina, perivascular, chronicpul,
  connectivetissue, mildliver, hemiplegia, diawithchronic, severeliver,
  aids, cardiacfailureiii, cerebrovascular, severeresp, pepticulcer,
  diabetes, severekidney, malignancy, tumour, dementia, renalfailure,
  electivesurgery, emergencysurgery:

  comorbidities, \`"Y"\` or \`"N"\` (a few missing)

- timetoadm:

  days from onset to admission

- incubationperiod, incuperiodonset:

  incubation period and period of onset (often missing)

- wound:

  \`"Deep"\` or \`"Superficial/other"\`

- diffbreath:

  difficulty breathing, \`"Y"\` or \`"N"\`

- ablettscore:

  Ablett score, \`"I"\`, \`"II"\` or \`"III"\`

- asa:

  ASA physical status, 1 to 3

- maxtemp, resp, fio2, spo2, pao2, ph, plt, wbc, hct, maxhr, minhr,
  maxsbp, worstdbp, worstsbp, na, k, creat:

  vital signs and laboratory values (\`pao2\` and \`ph\` mostly missing)

- vaso:

  vasopressors, \`"Y"\` or \`"N"\`

- apacheii, sofa, tss:

  APACHE II, SOFA and tetanus severity scores

- Arm:

  randomised arm, \`"Intrathecal treatment"\` or \`"Sham procedure"\`

- pain_score:

  pain score, 1 to 5

## Source

Simulated with \`data-raw/simulate_data.R\`.

## See also

\[ae_data\], \[sstable.baseline()\]
