# homebrew-tap

Homebrew formulae and casks for [Eddy Sant](https://github.com/eddysant)'s tools.

```sh
brew install --cask eddysant/tap/siftr
brew install eddysant/tap/mediate
brew install --cask eddysant/tap/photo-slap
```

After tapping once with `brew tap eddysant/tap`, the shorter names also work:

```sh
brew install --cask siftr
```

| Package | Description |
|---|---|
| [`siftr`](Casks/siftr.rb) (cask) | [Find media by example](https://github.com/eddysant/siftr): drop a folder of photos on a tag to teach it, then search your library for everything that matches. macOS app (Apple Silicon) |
| [`siftr`](Formula/siftr.rb) (formula) | The engine behind the app — CLIP embeddings, face recognition, duplicate detection — usable on its own as a CLI |
| [`mediate`](Formula/mediate.rb) | [Media library standardizer](https://github.com/eddysant/mediate): photos → lossless WebP, videos → compatible MP4, originals Trashed only after strict validation; filename standardization with undo |
| [`photo-slap`](Casks/photo-slap.rb) | [Retro-styled photo and video slideshow](https://github.com/eddysant/photo-slap-modern) for macOS (Apple Silicon) |

## siftr: which one do I want?

The cask is the app and the formula is the engine it drives. The cask depends on
the formula, so **`brew install --cask siftr` gets you both** — the app finds the
engine on its own, with no pip step and nothing to configure.

Install the formula alone only if you want the `siftr` command without the app.
The engine is roughly 1.2 GB of models either way, downloaded on first use rather
than at install time.

siftr is currently unsigned, so after installing or upgrading the cask you may
need to clear the quarantine flag once:

```sh
xattr -dr com.apple.quarantine /Applications/siftr.app
```

## Updates

Three scheduled workflows watch GitHub Releases daily and commit new versions
and verified checksums to this tap, staggered so they do not race each other
pushing here: [siftr](.github/workflows/update-siftr-cask.yml) (cask and formula
together, since the app and engine ship as one release),
[mediate](.github/workflows/update-mediate-formula.yml), and
[photo-slap](.github/workflows/update-photo-slap-cask.yml).
