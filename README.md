# Yandow Walker Construction Inc.

The live website is maintained directly in the repository root. GitHub Pages serves the committed files without a build step or script execution.

## Source files

- `index.html` — page content, navigation, metadata, and project-inquiry form.
- `css/site.css` — responsive styles; colors and typography are centralized in `:root`.
- `js/site.js` — responsive navigation and project-details validation.
- `images/Logo/Yandow Walker.png` — original full-color logo referenced directly by the header.
- `assets/` — hero imagery, footer logo, and favicon; original artwork also remains in `images/Logo/`.
- `.nojekyll` — direct static publishing.
- `CNAME` — existing custom domain, `yandowwalkerconstruction.com`.

Logo dimensions and responsive display sizing are set in HTML and CSS. Keep asset URLs relative and preserve filename casing. There is no separate deployment folder, archived mockup, framework, backend, or asset-generation script. Earlier designs remain in Git history.

## Preview and update

Open `index.html` for a quick visual preview, or use any static HTTP server. For example, if Python is installed, run `python -m http.server 8080` from this folder and open http://localhost:8080/.

Edit the source files, review the changes, then commit and push to `main`. GitHub Pages is configured at **Settings → Pages → Deploy from a branch → main → / (root)**. Check the repository's Actions tab for the deployment result. No GitHub setting change is needed for this layout.

## Content review

See [CONTENT-REVIEW.md](CONTENT-REVIEW.md) for facts and copy requiring company approval. The house illustration is not a completed company project. All contact navigation leads to one form with name, reply email, and project details. Send opens a pre-populated draft in the visitor's email application using `mailto:`; they must send it there. The destination address is not displayed in the form, but is necessarily present in its source. No email is sent by the website, and form values remain available if no email app opens. Replace this temporary handoff with a server-backed submission endpoint later.
