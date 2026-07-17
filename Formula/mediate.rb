class Mediate < Formula
  desc "Standardize a media library: photos to lossless WebP, videos to MP4, validated-then-Trash"
  homepage "https://github.com/eddysant/mediate"
  url "https://github.com/eddysant/mediate/archive/refs/tags/v0.4.0.tar.gz"
  sha256 "54f0f02774813d48ba1af527583d18f32fad5718e61c1e19f19f58ee0f8c191a"
  license "MIT"

  depends_on "ffmpeg"
  depends_on "python@3.14"
  depends_on "webp"

  def install
    libexec.install "mediate"
    python = Formula["python@3.14"].opt_bin/"python3.14"
    (bin/"mediate").write <<~SH
      #!/bin/bash
      PYTHONPATH="#{libexec}" exec "#{python}" -m mediate "$@"
    SH
  end

  def caveats
    <<~EOS
      exiftool is optional but recommended — it powers metadata validation,
      --date-prefix, and Live Photo verification:
        brew install exiftool
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/mediate --version")
  end
end
