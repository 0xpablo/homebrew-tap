class Libfsapfs < Formula
  desc "Library to access the Apple File System (APFS)"
  homepage "https://github.com/0xpablo/libfsapfs"
  url "https://github.com/0xpablo/libfsapfs/archive/f6bfe1a.tar.gz"
  version "f6bfe1a"
  sha256 "c18d9e40ab51518b8189af86b890f1e664fc96edb93051a0806449f270f89669"
  license "LGPL-3.0-or-later"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "gettext" => :build
  depends_on "libtool" => :build
  depends_on "pkgconf" => :build
  depends_on "libbfio"
  depends_on "openssl@3"

  def install
    openssl = Formula["openssl@3"]

    ENV.append "CPPFLAGS", "-I#{openssl.opt_include}"
    ENV.append "LDFLAGS", "-L#{openssl.opt_lib}"
    ENV.prepend_path "PKG_CONFIG_PATH", "#{openssl.opt_lib}/pkgconfig"
    ENV.prepend_path "PKG_CONFIG_PATH", "#{Formula["libbfio"].opt_lib}/pkgconfig"

    # libfsapfs uses libyal "synclibs" to vendor its local dependencies.
    # Homebrew builds are sandboxed by default; if this step fails due to
    # blocked network access, retry with `HOMEBREW_NO_SANDBOX=1`.
    system "./synclibs.sh"

    system "autoreconf", "-fi"
    system "./configure", *std_configure_args,
                          "--with-openssl=#{openssl.opt_prefix}",
                          "--enable-openssl-evp-cipher",
                          "--enable-openssl-evp-md",
                          "--enable-debug-output"
    system "make", "install"
  end

  test do
    assert_match "fsapfsinfo", shell_output("#{bin}/fsapfsinfo -V")
  end
end
