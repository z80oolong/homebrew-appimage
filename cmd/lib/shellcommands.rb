require "singleton"
require "shellwords"

module AppImage
  class ShellCommands
    include Singleton

    def initialize
      @patchelf ||= (Formula["patchelf"].opt_bin/"patchelf")
      @appimagetool ||= (Formula["z80oolong/appimage/appimagetool"].opt_bin/"appimagetool")
      @runtime ||= (Formula["z80oolong/appimage/appimage-runtime"].opt_libexec/"runtime-x86_64")
      @curl ||= Pathname.new(%x{which curl}.chomp!)
      @sha256sum ||= Pathname.new(%x{which sha256sum}.chomp!)
      @gpg2 ||= Pathname.new(%x{which gpg}.chomp!)
      @ldd ||= Pathname.new(%x{which ldd}.chomp!)
      @cp ||= Pathname.new(%x{which cp}.chomp!)
      @ln ||= Pathname.new(%x{which ln}.chomp!)

      unless @patchelf.executable? then
        system "brew reinstall -s patchelf"
      end

      unless @appimagetool.executable? then
        system "brew reinstall appimagetool"
      end

      unless @runtime.executable? then
        system "brew reinstall appimage-runtime"
      end

      unless @curl.executable? then
        system "brew reinstall curl"
        @curl = (Formula["curl"].opt_bin/"curl")
      end

      unless @gpg2.executable? then
        system "brew reinstall gpg2"
        @gpg2 = (Formula["gpg2"].opt_bin/"gpg")
      end

      unless @ldd.executable? then
        system "brew reinstall glibc"
        @ldd = (Formula["glibc"].opt_bin/"ldd")
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
