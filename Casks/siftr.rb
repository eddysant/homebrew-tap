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
    siftr ships the interface only. Its engine — CLIP embeddings and face
    recognition — is a Python package, installed separately because torch alone
    would add roughly 600 MB to this download:

      pip install "siftr[ui,faces] @ git+https://github.com/eddysant/siftr"

    A packaged app does not inherit your shell PATH, so if siftr lives in a
    virtualenv, point at it directly:

      SIFTR_BIN=/path/to/.venv/bin/siftr open -a siftr

    siftr is currently unsigned. If macOS reports that it is damaged, clear the
    quarantine flag once after installation:

      xattr -cr /Applications/siftr.app
  EOS
end
