# Building blocks of the flextables made by sstable.baseline(), sstable.ae(),
# sstable.survcomp() and sstable.survcomp.subgroup(). (Each used to carry its
# own copy of this code.)

# A flextable of `data` with two header rows: `header1` (top) and `header2`.
# Cells with the same text are merged horizontally (if `merge.h`) and
# vertically, as before. Labels are passed as values, not pasted into code, so
# header text may contain quotes.
._ss_flextable_two_headers <- function(data, header1, header2, merge.h = TRUE) {
  keys <- paste0("V", seq_along(header1))
  tab <- flextable::flextable(data)
  tab <- flextable::set_header_labels(tab, values = stats::setNames(as.list(header1), keys))
  tab <- flextable::add_header(tab, values = stats::setNames(as.list(header2), keys), top = FALSE)
  if (merge.h) tab <- flextable::merge_h(tab, part = "header")
  flextable::merge_v(tab, part = "header")
}

# One footer row per element of `footer`, each spanning all `ncol` columns
._ss_flextable_footer <- function(tab, footer, ncol) {
  for (k in seq_along(footer)) {
    tab <- flextable::add_footer(tab, V1 = footer[k], top = FALSE)
    tab <- flextable::merge_at(tab, i = k, j = seq_len(ncol), part = "footer")
  }
  tab
}

# Column widths, left-aligned first column and the sstable theme
._ss_flextable_finish <- function(tab, bg) {
  tab <- flextable::autofit(tab)
  tab <- flextable::align(tab, j = 1, align = "left", part = "all")
  ft_sstheme(tab, bg = bg)
}
