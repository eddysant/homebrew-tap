class Siftr < Formula
  include Language::Python::Virtualenv

  desc "Find media by example: teach a tag with example photos, then search"
  homepage "https://github.com/eddysant/siftr"
  url "https://github.com/eddysant/siftr/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "d8bacbdd998ecd35b872531f578cea64fac173f38ed0ffca0fff045844ab4c2f"
  license "MIT"

  depends_on "ffmpeg"
  depends_on "libheif"
  depends_on "python@3.12"
  # Video frame sampling shells out to ffmpeg when PyAV is absent.
  # pillow-heif links libheif; without HEIC, most of a Mac photo library is
  # unreadable.

  def install
    # Deliberately not `virtualenv_install_with_resources`. That needs every
    # transitive dependency pinned as a `resource`, and torch is ~590 MB of
    # platform-specific wheels that do not resource cleanly — the reason this
    # formula did not exist sooner. Letting pip resolve inside the virtualenv
    # keeps it maintainable at the cost of network access during install, which
    # is an acceptable trade for a personal tap.
    virtualenv_create(libexec, "python3.12")

    # NOT `venv.pip_install`, which passes --no-deps and would install a siftr
    # that cannot import numpy. Homebrew creates the virtualenv --without-pip,
    # so this drives the formula python's pip at it, the same way Homebrew's own
    # helper does, but with resolution left on.
    system formula_opt_bin("python@3.12")/"python3.12", "-m", "pip", "install",
           "--python=#{libexec}/bin/python", "--no-cache-dir", "--quiet",
           "#{buildpath}[ui,faces,video]"

    bin.install_symlink libexec/"bin/siftr"
  end

  def caveats
    <<~EOS
      Models (~1.2 GB of CLIP and InsightFace weights) download on first use,
      not now. They are cached in ~/.cache/huggingface and ~/.insightface.

      The desktop app is a separate cask:
        brew install --cask eddysant/tap/siftr
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/siftr --version")
    # A real end-to-end check would download CLIP; exercising the database and
    # argument paths proves the install without a 600 MB side effect.
    system bin/"siftr", "--db", "#{testpath}/index.db", "status"
    assert_path_exists testpath/"index.db"
  end
end
