class Libfsapfs < Formula
  desc "Library to access the Apple File System (APFS)"
  homepage "https://github.com/libyal/libfsapfs"
  url "https://github.com/libyal/libfsapfs/releases/download/20240429/libfsapfs-experimental-20240429.tar.gz"
  sha256 "665f70705e69ce90c87e0f9c185d47002e242b79b0a37ae52751cdfa8363a538"
  license "LGPL-3.0-or-later"

  depends_on "pkgconf" => :build
  depends_on "openssl@3"

  # Fixes a build failure in the vendored libcaes when OpenSSL headers are
  # available but EVP AES support is not detected, by ensuring the local AES
  # implementation is compiled in that situation.
  patch :DATA

  def install
    openssl = Formula["openssl@3"]

    ENV.append "CPPFLAGS", "-I#{openssl.opt_include}"
    ENV.append "LDFLAGS", "-L#{openssl.opt_lib}"
    ENV.prepend_path "PKG_CONFIG_PATH", "#{openssl.opt_lib}/pkgconfig"

    system "./configure", *std_configure_args,
                          "--with-openssl=#{openssl.opt_prefix}",
                          "--enable-openssl-evp-cipher",
                          "--enable-openssl-evp-md"
    system "make", "install"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/fsapfsinfo -V")
  end
end

__END__
diff --git a/libcaes/libcaes_definitions.h b/libcaes/libcaes_definitions.h
index 296b431..4fd3e9f 100644
--- a/libcaes/libcaes_definitions.h
+++ b/libcaes/libcaes_definitions.h
@@ -50,12 +50,14 @@ enum LIBCAES_CRYPT_MODES
 };
 
 #endif /* !defined( HAVE_LOCAL_LIBCAES ) */
 
-#if defined( HAVE_LIBCRYPTO ) && defined( HAVE_OPENSSL_AES_H )
+#if defined( HAVE_LIBCRYPTO ) && defined( HAVE_OPENSSL_AES_H ) \
+ && ( defined( HAVE_AES_CBC_ENCRYPT ) || defined( HAVE_AES_ECB_ENCRYPT ) )
 #define LIBCAES_HAVE_AES_SUPPORT
 
-#elif defined( HAVE_LIBCRYPTO ) && defined( HAVE_OPENSSL_EVP_H )
+#elif defined( HAVE_LIBCRYPTO ) && defined( HAVE_OPENSSL_EVP_H ) \
+ && ( defined( HAVE_EVP_CRYPTO_AES_CBC ) || defined( HAVE_EVP_CRYPTO_AES_ECB ) )
 #define LIBCAES_HAVE_AES_SUPPORT
 
 #endif
