class Libbfio < Formula
  desc "Library to provide basic file input/output abstraction"
  homepage "https://github.com/libyal/libbfio"
  url "https://github.com/libyal/libbfio/archive/f258de12eee29a7516a16393a167e7362213bb47.tar.gz"
  version "f258de12eee29a7516a16393a167e7362213bb47"
  sha256 "0a5ffb917e68975360bc30990e6f654364b978d2a6771458b5e6a8ea8219520c"
  license "LGPL-3.0-or-later"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "gettext" => :build
  depends_on "libtool" => :build
  depends_on "pkgconf" => :build

  def install
    # libbfio uses libyal "synclibs" to vendor its local dependencies.
    # Homebrew builds are sandboxed by default; if this step fails due to
    # blocked network access, retry with `HOMEBREW_NO_SANDBOX=1`.
    system "./synclibs.sh"

    system "autoreconf", "-fi"
    system "./configure", *std_configure_args
    system "make", "install"
  end

  test do
    assert_match "libbfio", shell_output("#{bin}/bfioinfo -V")
  end
end
