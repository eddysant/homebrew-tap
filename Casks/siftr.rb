cask "siftr" do
  version "0.1.0"
  sha256 "c9bac13b378c4241f0ca3d7ee79c8bc1fd96508d054518b695796734fcd62654"

  url "https://github.com/eddysant/siftr/releases/download/v#{version}/siftr-#{version}-arm64.dmg"
  name "siftr"
  desc "Find media by example: teach a tag with a folder of photos, then search"
  homepage "https://github.com/eddysant/siftr"

  livecheck do
    strategy :github_latest
  end

  # The app is the interface; this is the engine it drives. Declaring it means
  # `brew install --cask siftr` gets a working install in one command, with no
  # pip step and no SIFTR_BIN — /opt/homebrew/bin is one of the paths the app
  # probes, so it finds the formula's `siftr` on its own.
  depends_on formula: "eddysant/tap/siftr"
  depends_on arch: :arm64
  depends_on macos: :monterey

  app "siftr.app"

  zap trash: [
    "~/.siftr",
    "~/Library/Application Support/siftr",
    "~/Library/Preferences/dev.eddysant.siftr.plist",
    "~/Library/Saved Application State/dev.eddysant.siftr.savedState",
  ]

  caveats <<~EOS
    The engine (CLIP and face recognition, ~1.2 GB) installs as the `siftr`
    formula alongside this app; models download on first use.

    siftr is currently unsigned. If macOS reports that it is damaged, clear the
    quarantine flag once after installation:

      xattr -cr /Applications/siftr.app
  EOS
end
