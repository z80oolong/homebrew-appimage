require "singleton"
require "shellwords"

module AppImage
  class ShellCommands
    include Singleton

    def initialize
      @patchelf     ||= (Formula["patchelf"].opt_bin/"patchelf")
      @appimagetool ||= (Formula["z80oolong/appimage/appimagetool"].opt_bin/"appimagetool")
      @runtime      ||= (Formula["z80oolong/appimage/appimage-runtime"].opt_libexec/"runtime-x86_64")
      @ldd          ||= (Formula["glibc"].opt_bin/"ldd")
      @curl         ||= Pathname.new(%x{which curl}.chomp!)
      @sha256sum    ||= Pathname.new(%x{which sha256sum}.chomp!)
      @gpg2         ||= Pathname.new(%x{which gpg}.chomp!)
      @cp           ||= Pathname.new(%x{which cp}.chomp!)
      @ln           ||= Pathname.new(%x{which ln}.chomp!)

      if !@patchelf.executable? then
        system "brew", "reinstall", "-s", "patchelf"
        @patchelf = (Formula["patchelf"].opt_bin/"patchelf")
      end

      if !@appimagetool.executable? then
        system "brew", "reinstall", "appimagetool"
        @appimagetool = (Formula["z80oolong/appimage/appimagetool"].opt_bin/"appimagetool")
      end

      if !@runtime.executable? then
        system "brew", "reinstall", "appimage-runtime"
        @runtime = (Formula["z80oolong/appimage/appimage-runtime"].opt_libexec/"runtime-x86_64")
      end

      if !@curl.executable? then
        system "brew", "reinstall", "curl"
        @curl = (Formula["curl"].opt_bin/"curl")
      end

      if !@gpg2.executable? then
        system "brew", "reinstall", "gpg2"
        @gpg2 = (Formula["gpg2"].opt_bin/"gpg")
      end

      if !@ldd.executable? then
        @ldd ||= Pathname.new(%x{which ldd}.chomp!)
      end

      unless (@sha256sum.executable? || @cp.executable? || @ln.executable?) then
        system "brew reinstall coreutils"
        @sha256sum = (Formula["coreutils"].opt_bin/"gsha256sum")
        @cp = (Formula["coreutils"].opt_bin/"gcp")
        @ln = (Formula["coreutils"].opt_bin/"gln")
      end
    end

    attr_reader :patchelf, :appimagetool, :runtime, :curl, :gpg2, :ldd
    attr_reader :sha256sum, :cp, :ln
  end
end
