class Mediate < Formula
  desc "Standardize photos and videos with strict validation before trashing originals"
  homepage "https://github.com/eddysant/mediate"
  url "https://github.com/eddysant/mediate/archive/refs/tags/v0.19.0.tar.gz"
  sha256 "c2f3345e00268c9418f7e6b0e7970d9d4af8760e5ddb354b8298af34c2e6f692"
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
