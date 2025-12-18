class Libfsapfs < Formula
  desc "Library to access the Apple File System (APFS)"
  homepage "https://github.com/0xpablo/libfsapfs"
  url "https://github.com/0xpablo/libfsapfs/archive/192ede6f30b2a413d01731a4bdab52d0f94ac9a5.tar.gz"
  sha256 "05c4a9a24b9e99e088e112a9466bfa43b1fc0c1ee0d63d827900b6dc228a1aa6"
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
