## 0.0.1

* just added files

## 0.0.2

* added screenshots

## 0.0.3

* updated readme file

## 0.0.4

* updated readme file

## 0.0.5

* remove  files

## 0.0.6

* Add `AdaptiveSpinnerLayout`: spinner rows now size to their intrinsic width
  and scale down (instead of clipping) when the available width is too small.
  Fixes the AM/PM column being cut off in 12-hour mode and makes every picker
  robust to locale and text-scale changes.
* Time, duration and number pickers now build on `AdaptiveSpinnerLayout`.
* Dialog `width` is now optional (`double?`). When omitted, the dialog content
  sizes itself to the picker and is capped at the available width — no more
  hard-coded per-format widths at the call site.
* Unit separators (`:`, `h`, `m`, `s`, custom number units) now reserve their
  spacing as a *minimum* width and shrink-wrap their glyph, so a wide glyph is
  never clipped (previously caused small RenderFlex overflows) and is never
  forced to an unbounded size inside the adaptive layout.
* The coloured spinner box now sizes to the widest digit plus a
  font-proportional horizontal padding (new `RawNumberSpinnerOptions
  .digitHorizontalPadding`, `null` = auto), using the configured `width` only
  as a floor — so digits keep breathing room at large font / text-scale sizes
  instead of touching the edges.
* Added widget regression tests asserting the time (12h/24h), duration and
  number pickers never overflow when rendered in a too-narrow box, and that the
  box grows to pad a large font.
