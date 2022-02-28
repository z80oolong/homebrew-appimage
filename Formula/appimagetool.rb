class Appimagetool < Formula
  desc "Package desktop applications as AppImages that run on common Linux-based operating systems, "\
       "such as RHEL, CentOS, openSUSE, SLED, Ubuntu, Fedora, debian and derivatives."
  homepage "http://appimage.org"
  url "https://github.com/AppImage/AppImageKit/releases/download/13/appimagetool-x86_64.AppImage"
  sha256 "df3baf5ca5facbecfc2f3fa6713c29ab9cefa8fd8c1eac5d283b79cab33e4acb"
  version "13"
  license "MIT"

  option "with-extract", "Extract appimagetool AppImage."

  def install
    (buildpath/"appimagetool-x86_64.AppImage").chmod(0755)
    bin.mkdir; libexec.mkdir

    if build.with?("extract") then
      libexec.cd do
        system "#{buildpath}/appimagetool-x86_64.AppImage", "--appimage-extract"
      end
      bin.install_symlink (libexec/"squashfs-root/AppRun") => "appimagetool"
    else
      (libexec/"bin").mkpath
      (libexec/"bin").install "#{buildpath}/appimagetool-x86_64.AppImage"
      bin.install_symlink (libexec/"bin/appimagetool-x86_64.AppImage") => "appimagetool"
    end
  end

  test do
    system "#{bin}/appimagetool --version"
  end
end
