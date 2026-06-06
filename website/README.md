# Design Patterns — Hugo Site

This folder contains the [Hugo Book](https://github.com/alex-shpak/hugo-book) site that publishes the documentation to GitHub Pages.

## Branch layout

| Branch | Purpose |
|--------|---------|
| `master` | Plain Markdown source (`README.md` per pattern folder) |
| `gh-pages` | Auto-generated static site (do not edit manually) |

Readers who prefer raw Markdown can browse `master` on GitHub. The published site is available at:

**https://amirmahdikahdouii.github.io/Design-Patterns/**

## One-time GitHub Pages setup

After the first successful CI deploy creates the `gh-pages` branch:

1. Open **Settings → Pages** in the GitHub repository
2. Set **Source** to **Deploy from a branch**
3. Choose branch **`gh-pages`** and folder **`/ (root)`**
4. Save — the site will be live within a few minutes

## Local development

Requires **Hugo Extended 0.158.0 or newer**.

```bash
# From the repository root
bash scripts/setup-theme.sh   # clones hugo-book v0.14.0 (once)
bash scripts/sync-content.sh  # copies README.md files into website/content/
cd website && hugo server -D
```

Preview at http://localhost:1313/Design-Patterns/

## How content sync works

`scripts/sync-content.sh` runs before every build (locally and in CI). It:

- Splits the root `README.md` into a home page and a fundamentals page
- Auto-discovers all `*-Patterns/*/README.md` files
- Copies images into `website/static/images/`
- Rewrites internal links and image paths for the published site
- Injects Hugo front matter (`title`, `weight`, `source_path`)

**You only edit Markdown on `master`.** Never edit `website/content/` directly — it is regenerated on each build.

## Deployment

Pushes to `master` that touch Markdown, assets, `website/`, or `scripts/` trigger [`.github/workflows/deploy.yml`](../.github/workflows/deploy.yml), which:

1. Installs Hugo 0.158.0 (extended)
2. Installs the Hugo Book theme
3. Syncs content
4. Builds the site
5. Publishes to the `gh-pages` branch

You can also trigger a deploy manually from the **Actions** tab via **workflow_dispatch**.
