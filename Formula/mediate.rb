class Mediate < Formula
  desc "Standardize photos and videos with strict validation before trashing originals"
  homepage "https://github.com/eddysant/mediate"
  url "https://github.com/eddysant/mediate/archive/refs/tags/v0.8.4.tar.gz"
  sha256 "2aa9c6e5ca23c521bceed6706fa86781d392aea0d0749ec230f3986c5c7f2ced"
  license "MIT"

  depends_on "exiftool"
  depends_on "ffmpeg"
  depends_on "jpeg-turbo"
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

  test do
    assert_match version.to_s, shell_output("#{bin}/mediate --version")
  end
end
