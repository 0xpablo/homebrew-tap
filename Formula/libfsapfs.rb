class Libfsapfs < Formula
  desc "Library to access the Apple File System (APFS)"
  homepage "https://github.com/0xpablo/libfsapfs"
  url "https://github.com/0xpablo/libfsapfs/archive/b31a665d8f47343b6de91408a0f7a606d94ceeba.tar.gz"
  sha256 "0cc763d98fa98b5dcadd4146cd41d9b87e2f050b93fca7b478bae1476809ecde"
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
