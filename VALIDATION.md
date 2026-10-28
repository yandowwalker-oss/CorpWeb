# Validation record

Validated locally on October 28, 2026. The initial build was local-only; the owner subsequently authorized committing and pushing. The owner's existing remote CNAME is preserved in the published directory. No GitHub settings or DNS changes were performed.

## Checks performed

- Served `docs/` over HTTP; both `/` and `/CorpWeb/` returned HTTP 200.
- In headless Microsoft Edge, fetched every deployed image, `srcset` candidate, stylesheet, script, and favicon at both URL bases. All resolved. All anchors target existing IDs. External JavaScript parsed and ran without page exceptions or console errors.
- Checked document and visible element bounds at widths **1440, 1024, 768, 760, 390, and 320px**; no horizontal overflow. Captured and visually reviewed full-page screenshots at 1440, 768, and 390px for responsive sections, text hierarchy, and the supplied design direction.
- Checked mobile menu opening, section-link closure, outside-click closure, Escape, focus restoration, and desktop-resize reset.
- Checked all **six** project CTAs and service-specific type selection.
- Checked required-field and email validation, whitespace-only name rejection, brief generation, output focus, and stale-brief removal after input changes.
- The native asynchronous clipboard-write call resolved and displayed copy confirmation. Simulated clipboard denial and confirmed selected text plus manual-copy instructions. All confirmation states explicitly say nothing was sent.
- Used actual DevTools keyboard events for Tab, Shift+Tab, and Escape. Confirmed dialog focus wrapping, initial title focus, close-button focus restoration, backdrop dismissal, and visible mobile-menu fallback when the original opener is hidden. Confirmed keyboard skip-link order and main focus. Scrolled to load and decode all images, including the footer logo.
- Inspected transparent logo variants and sampled the full-color PNG's red (`#ae0400`). Web copies retain entire proportional artwork. Main hero uses the supplied illustration with visible illustrative-image captions.
- Ran `git diff --check` and source-level relative-reference/case checks. Public assets do not depend on external files, filesystem paths, fonts, or scripts.

## Limits

- Local Edge checks do not verify live Pages hosting. Repository/account eligibility and remote settings remain unverified.
- Physical devices, Safari, Firefox, screen readers, and high-zoom testing were not available. Native clipboard readback was not confirmed; write resolution and denied-write fallback were checked.
- Styling uses dark green/cream, white-on-logo-red buttons, darker secondary text, and visible focus outlines. No full WCAG conformance audit is claimed.
- Canonical/social-image URLs require the final public address. Company services, process, and copy need approval in `CONTENT-REVIEW.md`.

Re-run with `scripts/validate-site.ps1` and the README instructions. Screenshots and disposable browser data live in ignored `.local-preview/`, outside the published directory.
