class Mediate < Formula
  desc "Standardize photos and videos with strict validation before trashing originals"
  homepage "https://github.com/eddysant/mediate"
  url "https://github.com/eddysant/mediate/archive/refs/tags/v0.7.0.tar.gz"
  sha256 "11334699899d45852e6459d875bb38c73a680edc88b82aeb234276433d0bd6e2"
  license "MIT"

  depends_on "ffmpeg"
  depends_on "python@3.14"
  depends_on "webp"

  def install
    libexec.install "mediate"
    python = formula_opt_bin("python@3.14")/"python3.14"
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
