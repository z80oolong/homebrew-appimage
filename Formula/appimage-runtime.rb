# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class AppimageRuntime < Formula
  desc "Runtime routine for AppImage package file (arch x86_64)"
  homepage "https://docs.appimage.org/index.html"
  license "MIT"

  stable do
    url "https://github.com/AppImage/AppImageKit/releases/download/13/runtime-x86_64"
    sha256 "328e0d745c5c6817048c27bc3e8314871703f8f47ffa81a37cb06cd95a94b323"
    version "13"
  end

  head do
    url "https://github.com/AppImage/AppImageKit/releases/download/continuous/runtime-x86_64"
  end

  def install
    libexec.install buildpath/"runtime-x86_64"
    (libexec/"runtime-x86_64").chmod(0755)
  end

  test do
    system "#{opt_libexec}/runtime-x86_64", "--appimage-help"
  end
end
