# Yandow Walker Construction Inc.

A buildless first draft for Kauaʻi, Hawaiʻi, based on the supplied plantation-home mockup. Deployable files are in **`docs/`**. No framework, package installation, backend, database, third-party fonts, or deployment workflow is required.

The site is prepared for deployment; company content still needs approval. See [CONTENT-REVIEW.md](CONTENT-REVIEW.md) before public launch. The project dialog prepares a brief to copy and **does not send an inquiry**.

## Files and editing

| Location | Purpose |
| --- | --- |
| `docs/index.html` | Content, sections, metadata, and accessible project dialog |
| `docs/css/site.css` | Styling; centralized colors and typography in `:root` |
| `docs/js/site.js` | Menu, dialog focus, validation, and brief copying |
| `docs/assets/` | Optimized public images/logos and favicon |
| `docs/.nojekyll` | Serve files directly through GitHub Pages |
| `index.html` | Original mockup, preserved as supplied |
| `assets/kauai-plantation-home-original.png` | Original hero illustration, preserved |
| `images/Logo/` | Original official PNG/JPG/PDF/EPS/AI logos, preserved |
| `scripts/` | Optional local preview and validation tools; never part of deployment |

The actual source directory is lowercase `images/Logo/`. Keep exact filename casing on GitHub. Only `docs/` is published. Keep deployment links relative so they work at both a domain root and a repository subpath.

The light header uses an exact copy of `images/Logo/Yandow Walker.png`, published as `docs/images/Logo/Yandow Walker.png`. Its URL is relative and space-encoded for repository-subpath compatibility. The cream PNG is used on the dark footer. Full canvases and transparent margins are retained; do not crop, stretch, recolor, or filter the logos. Button red `#ae0400` comes from the full-color artwork. Hero copies are quality-90 JPEGs at 1536 and 960 pixels, selected with `srcset`; the original PNG remains intact. Images have explicit dimensions; the hero has high fetch priority and lower images load lazily.

## Preview locally

From the repository root in PowerShell:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/preview.ps1
```

Open **http://localhost:8080/**. Also check **http://localhost:8080/CorpWeb/** for repository-subpath behavior. The server serves `docs/` on loopback only. Stop with Ctrl+C. Add `-Port 8081` if needed. ExecutionPolicy Bypass applies only to that process; it does not change machine policy.

Alternatively, with Python installed:

```powershell
python -m http.server 8080 --directory docs
```

Use HTTP preview for clipboard tests. If automatic copying is denied, the dialog selects the brief and explains manual copying. There is no local storage, network submission, analytics, or external dependency.

All public images are already prepared and committed. The header references its committed PNG directly in `docs/index.html`; CSS sets its display size to 156 × 156px on desktop and 120 × 120px on mobile. GitHub Pages serves these files as-is. No asset-generation script or manual preparation step is required.

## Validation

See [VALIDATION.md](VALIDATION.md) for completed checks and limits. The repeatable `scripts/validate-site.ps1` uses PowerShell/.NET and Edge DevTools. Start the preview on port 8080. In a separate PowerShell terminal, start a dedicated headless Edge instance on port 9222:

```powershell
New-Item -ItemType Directory -Force .local-preview | Out-Null
& 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe' --headless=new --disable-gpu --no-first-run --remote-debugging-port=9222 --user-data-dir="$PWD/.local-preview/edge-profile" about:blank
```

Then, from another terminal at the repository root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/validate-site.ps1
```

The browser must expose `http://localhost:9222/json/list`. Tests enter synthetic data, exercise clipboard writing (overwriting clipboard contents), and save screenshots under ignored `.local-preview/`. Close the dedicated browser after testing. This task's restricted environment required `--in-process-gpu --no-sandbox` for its isolated headless browser; normal workstation preview should not need those flags. Native clipboard readback was not verified.

## Commit and push when approved

The initial draft was prepared locally; the repository owner subsequently authorized committing and pushing it. The default branch is **`main`** (`origin/HEAD` → `origin/main`); the configured remote is `https://github.com/yandowwalker-oss/CorpWeb.git`. Use the following commands for future updates.

Review the files, including supplied originals that were initially untracked:

```powershell
git status --short
git diff --check
git add README.md CONTENT-REVIEW.md VALIDATION.md .gitignore docs scripts index.html assets images
git diff --cached --stat
git commit -m "Build Yandow Walker Construction website draft"
git push origin main
```

If branch protection requires a pull request, commit on a feature branch and merge through normal repository review instead.

## Enable GitHub Pages

After content approval and pushing/merging to `main`:

1. Open the repository on GitHub.
2. Go to **Settings → Pages → Build and deployment**.
3. Set **Source: Deploy from a branch**.
4. Select **`main`**, select **`/docs`**, then **Save**.
5. Wait for the Pages deployment to complete. Check **Actions** for the Pages build/deployment run and its successful result. GitHub can create its own Pages run; no custom workflow is needed.
6. Return to **Settings → Pages** and use the displayed **Visit site** link as the authoritative URL. It may take a few minutes to appear. Verify navigation, images, mobile layout, and the copy-only brief at that URL.

Repository admin access is required to change Pages settings. Visibility, organization policy, and the account's GitHub plan can affect availability; remote account settings were not available for verification during the initial build. The owner reports Pages is configured on `main`. The existing remote `CNAME` specifies `yandowwalkerconstruction.com`; it is preserved at the repository root and copied to `docs/CNAME` for the published site. Domain settings and DNS have not been changed or verified. Once the final working public URL is confirmed, complete canonical and social-image metadata in `CONTENT-REVIEW.md`.
