class Mediate < Formula
  desc "Standardize photos and videos with strict validation before trashing originals"
  homepage "https://github.com/eddysant/mediate"
  url "https://github.com/eddysant/mediate/archive/refs/tags/v0.15.0.tar.gz"
  sha256 "a98f08a22e0f510ee47cf55ed3aa5367ed0fbea33fc75043e5ebc9e6d8e91c7e"
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
