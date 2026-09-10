cask "photo-slap" do
  version "1.6.1"
  sha256 "a64be7687b742ef4cab645477de5674b7efe75bcd65d21380a243d33281df31e"

  url "https://github.com/eddysant/photo-slap-modern/releases/download/v#{version}/photo-slap-Mac-#{version}-Installer.dmg",
      verified: "github.com/eddysant/photo-slap-modern/"
  name "photo-slap"
  desc "Retro-styled photo and video slideshow"
  homepage "https://github.com/eddysant/photo-slap-modern"

  livecheck do
    strategy :github_latest
  end

  depends_on arch: :arm64
  depends_on macos: :monterey

  app "photo-slap.app"

  zap trash: [
    "~/Library/Application Support/photo-slap",
    "~/Library/Preferences/com.eddysant.photo-slap.plist",
    "~/Library/Saved Application State/com.eddysant.photo-slap.savedState",
  ]

  caveats <<~EOS
    photo-slap is currently unsigned. If macOS reports that it is damaged,
    clear the quarantine flag once after installation:
      xattr -cr /Applications/photo-slap.app
  EOS
end
