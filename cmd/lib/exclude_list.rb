module AppImage
  module Utils
    EXCLUDE_LIST = {
      "libanl.so.1" => true,
      "libBrokenLocale.so.1" => true,
      "libcidn.so.1" => true,
      "libc.so.6" => true,
      "libdl.so.2" => true,
      "libm.so.6" => true,
      "libmvec.so.1" => true,
      "libnss_compat.so.2" => true,
      "libnss_dns.so.2" => true,
      "libnss_files.so.2" => true,
      "libnss_hesiod.so.2" => true,
      "libnss_nisplus.so.2" => true,
      "libnss_nis.so.2" => true,
      "libpthread.so.0" => true,
      "libresolv.so.2" => true,
      "librt.so.1" => true,
      "libthread_db.so.1" => true,
      "libutil.so.1" => true,
      "libstdc++.so.6" => true,
      "libGL.so.1" => true,
      "libEGL.so.1" => true,
      "libGLdispatch.so.0" => true,
      "libGLX.so.0" => true,
      "libOpenGL.so.0" => true,
      "libdrm.so.2" => true,
      "libglapi.so.0" => true,
      "libgbm.so.1" => true,
      "libxcb.so.1" => true,
      "libX11.so.6" => true,
      "libgio-2.0.so.0" => true,
      "libasound.so.2" => true,
      "libfontconfig.so.1" => true,
      "libthai.so.0" => true,
      "libfreetype.so.6" => true,
      "libharfbuzz.so.0" => true,
      "libcom_err.so.2" => true,
      "libexpat.so.1" => true,
      "libgcc_s.so.1" => true,
      "libglib-2.0.so.0" => true,
      "libICE.so.6" => true,
      "libp11-kit.so.0" => true,
      "libSM.so.6" => true,
      "libusb-1.0.so.0" => true,
      "libuuid.so.1" => true,
      "libz.so.1" => true,
      "libgobject-2.0.so.0" => true,
      "libpangoft2-1.0.so.0" => true,
      "libpangocairo-1.0.so.0" => true,
      "libpango-1.0.so.0" => true,
      "libgpg-error.so.0" => true,
      "libjack.so.0" => true,
      "libxcb-dri3.so.0" => true,
      "libxcb-dri2.so.0" => true,
      "libfribidi.so.0" => true,
      "libgmp.so.10" => true
    }
  end
end
