# homebrew-tap

Homebrew formulae and casks for [Eddy Sant](https://github.com/eddysant)'s tools.

```sh
brew install eddysant/tap/mediate
brew install --cask eddysant/tap/photo-slap
```

| Formula | Description |
|---|---|
| [`mediate`](Formula/mediate.rb) | [Media library standardizer](https://github.com/eddysant/mediate): photos → lossless WebP, videos → compatible MP4, originals Trashed only after strict validation; filename standardization with undo |
| [`photo-slap`](Casks/photo-slap.rb) | [Retro-styled photo and video slideshow](https://github.com/eddysant/photo-slap-modern) for macOS (Apple Silicon) |

After tapping once with `brew tap eddysant/tap`, the shorter command also works:

```sh
brew install --cask photo-slap
```

The photo-slap Cask updater checks GitHub Releases daily and commits the latest version and verified DMG checksum to this tap.
