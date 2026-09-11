class Siftr < Formula
  include Language::Python::Virtualenv

  desc "Find media by example: teach a tag with example photos, then search"
  homepage "https://github.com/eddysant/siftr"
  url "https://github.com/eddysant/siftr/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "d8bacbdd998ecd35b872531f578cea64fac173f38ed0ffca0fff045844ab4c2f"
  license "MIT"

  # Video frame sampling shells out to ffmpeg when PyAV cannot decode a file.
  depends_on "ffmpeg"
  # pillow-heif links libheif. Without HEIC most of a Mac photo library is
  # unreadable, so this is a hard dependency rather than an extra.
  depends_on "libheif"
  depends_on "python@3.12"

  # Homebrew's cleaner strips Mach-O binaries, which invalidates the ad-hoc
  # signatures pip wheels ship on their bundled dylibs. Stripping a third-party
  # wheel buys nothing here and costs a working install.
  skip_clean "libexec"

  def install
    # Deliberately not `virtualenv_install_with_resources`. That needs every
    # transitive dependency pinned as a `resource`, and torch is ~590 MB of
    # platform-specific wheels that do not resource cleanly — the reason this
    # formula did not exist sooner. Letting pip resolve inside the virtualenv
    # keeps it maintainable, at the cost of network access during install, which
    # is an acceptable trade for a personal tap.
    virtualenv_create(libexec, "python3.12")

    # NOT `venv.pip_install`: that passes --no-deps and would install a siftr
    # which cannot import numpy. Homebrew creates the virtualenv --without-pip,
    # so this drives the formula python's pip at it the way Homebrew's own helper
    # does, but with resolution left on. --python must precede the subcommand.
    system formula_opt_bin("python@3.12")/"python3.12", "-m", "pip",
           "--python=#{libexec}/bin/python", "install", "--no-cache-dir",
           "#{buildpath}[ui,faces,video]"

    bin.install_symlink libexec/"bin/siftr"
  end

  # Two deliberate choices here:
  #
  # `post_install` rather than doing this in `install`, because Homebrew rewrites
  # Mach-O binaries (relocation, install-name fixing) *after* `install` returns.
  # That invalidates the ad-hoc signatures on the dylibs pip wheels bundle under
  # `.dylibs/`, and macOS then SIGKILLs any process that loads one — `from PIL
  # import Image` dies instantly, with no output and no traceback. Re-signing
  # after the rewriting is what makes the install usable. Wheels installed by
  # plain pip are never rewritten, which is why this only bites under brew.
  #
  # `post_install` rather than the `post_install_steps` the audit prefers,
  # because that is a declarative DSL with a fixed vocabulary and cannot express
  # "re-sign these binaries". `brew style` flags this; it is a deliberate,
  # unavoidable deviation and Homebrew does not permit inline disable comments.
  def post_install
    # FNM_DOTMATCH is essential: the bundled dylibs live in a *dotted* directory
    # (`.dylibs/`), which Dir.glob skips by default — and those are precisely the
    # files whose signatures were invalidated.
    machos = Dir.glob(
      "#{libexec}/lib/python3.12/site-packages/**/*.{so,dylib}",
      File::FNM_DOTMATCH,
    )
    ohai "Re-signing #{machos.count} Mach-O files"
    machos.each { |macho| system "/usr/bin/codesign", "--force", "--sign", "-", macho }
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
    # Loads Pillow's native extension and its bundled dylibs — the import that
    # Homebrew's binary rewriting silently kills without the re-signing above.
    system libexec/"bin/python", "-c", "from PIL import Image; import numpy"
    # A real end-to-end check would download CLIP; exercising the database and
    # argument paths proves the install without a 600 MB side effect.
    system bin/"siftr", "--db", "#{testpath}/index.db", "status"
    assert_path_exists testpath/"index.db"
  end
end
