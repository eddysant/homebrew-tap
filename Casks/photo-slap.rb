cask "photo-slap" do
  version "1.4.0"
  sha256 "d084a89c01ea34316b582ce5ce7f08afefa8fc2e92b7e51ad4529936b91f0f33"

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
