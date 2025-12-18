class Libfsapfs < Formula
  desc "Library to access the Apple File System (APFS)"
  homepage "https://github.com/0xpablo/libfsapfs"
  url "https://github.com/0xpablo/libfsapfs/archive/cfdf54be3737ed6c42802f8ed62cdfd7ed2cecb6.tar.gz"
  sha256 "e2ea36e0c277dd760962a3fcd939d8f6a5ce3623c8a7472c691846fe0f6242b4"
  license "LGPL-3.0-or-later"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "gettext" => :build
  depends_on "libtool" => :build
  depends_on "pkgconf" => :build
  depends_on "openssl@3"

  def install
    openssl = Formula["openssl@3"]

    ENV.append "CPPFLAGS", "-I#{openssl.opt_include}"
    ENV.append "LDFLAGS", "-L#{openssl.opt_lib}"
    ENV.prepend_path "PKG_CONFIG_PATH", "#{openssl.opt_lib}/pkgconfig"

    # libfsapfs uses libyal "synclibs" to vendor its local dependencies.
    # Homebrew builds are sandboxed by default; if this step fails due to
    # blocked network access, retry with `HOMEBREW_NO_SANDBOX=1`.
    system "./synclibs.sh"

    system "autoreconf", "-fi"
    system "./configure", *std_configure_args,
                          "--with-openssl=#{openssl.opt_prefix}",
                          "--enable-openssl-evp-cipher",
                          "--enable-openssl-evp-md"
    system "make", "install"
  end

  test do
    assert_match "fsapfsinfo", shell_output("#{bin}/fsapfsinfo -V")
  end
end
