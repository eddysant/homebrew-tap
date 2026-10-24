cask "photo-slap" do
  version "1.8.0"
  sha256 "44702970320828bbb934305032072c10dfd13d401b848d1379baf65fd7601e9c"

  url "https://github.com/eddysant/photo-slap-modern/releases/download/v#{version}/photo-slap-Mac-#{version}-Installer.dmg"
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
      xattr -dr com.apple.quarantine /Applications/photo-slap.app

    You will need this again after each upgrade: every install stages a fresh
    copy, so the flag comes back.
  EOS
end
